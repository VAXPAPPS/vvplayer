#include <gdk-pixbuf/gdk-pixbuf.h>
#include <glib.h>
#include <glib/gstdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

static char *get_thumbnail_path(const char *uri) {
    char *hash = g_compute_checksum_for_string(G_CHECKSUM_MD5, uri, -1);
    char *filename = g_strdup_printf("%s.png", hash);
    g_free(hash);
    
    const char *cache_dir = g_get_user_cache_dir();
    char *thumb_dir = g_build_filename(cache_dir, "thumbnails", "large", NULL);
    g_mkdir_with_parents(thumb_dir, 0700);
    
    char *thumb_path = g_build_filename(thumb_dir, filename, NULL);
    g_free(filename);
    g_free(thumb_dir);
    
    return thumb_path;
}

static void apply_film_strip(GdkPixbuf *pixbuf) {
    if (!pixbuf) return;
    int width = gdk_pixbuf_get_width(pixbuf);
    int height = gdk_pixbuf_get_height(pixbuf);
    int rowstride = gdk_pixbuf_get_rowstride(pixbuf);
    int n_channels = gdk_pixbuf_get_n_channels(pixbuf);
    guchar *pixels = gdk_pixbuf_get_pixels(pixbuf);
    
    int border_width = 20;
    int hole_size = 10;
    int hole_offset = 5;
    int hole_period = 24;
    
    for (int y = 0; y < height; y++) {
        guchar *row = pixels + y * rowstride;
        
        gboolean is_hole = FALSE;
        int y_mod = y % hole_period;
        if (y_mod >= 7 && y_mod < 7 + hole_size) {
            is_hole = TRUE;
        }
        
        for (int x = 0; x < width; x++) {
            if (x < border_width || x >= width - border_width) {
                guchar r = 15, g = 15, b = 15, a = 255;
                
                if (is_hole) {
                    if ((x >= hole_offset && x < hole_offset + hole_size) || 
                        (x >= width - border_width + hole_offset && x < width - border_width + hole_offset + hole_size)) {
                        r = 240; g = 240; b = 240;
                    }
                }
                
                guchar *p = row + x * n_channels;
                p[0] = r;
                p[1] = g;
                p[2] = b;
                if (n_channels == 4) p[3] = a;
            }
        }
    }
}

static GdkPixbuf *generate_video_thumbnail(const char *path) {
    char *tmp_filename = g_strdup_printf("thumb_%p_%d.png", path, g_random_int());
    char *tmp_path = g_build_filename(g_get_tmp_dir(), tmp_filename, NULL);
    g_free(tmp_filename);
    
    char *argv[] = {
        (char *)"ffmpeg", (char *)"-y", (char *)"-i", (char *)path,
        (char *)"-vf", (char *)"thumbnail,scale=256:256:force_original_aspect_ratio=increase,crop=256:256",
        (char *)"-frames:v", (char *)"1",
        tmp_path, NULL
    };
    
    gboolean success = g_spawn_sync(NULL, argv, NULL,
                                    (GSpawnFlags)(G_SPAWN_SEARCH_PATH | G_SPAWN_STDOUT_TO_DEV_NULL | G_SPAWN_STDERR_TO_DEV_NULL),
                                    NULL, NULL, NULL, NULL, NULL, NULL);
                                    
    GdkPixbuf *pixbuf = NULL;
    if (success) {
        pixbuf = gdk_pixbuf_new_from_file_at_scale(tmp_path, 256, 256, TRUE, NULL);
        if (pixbuf) {
            apply_film_strip(pixbuf);
        }
    }
    
    g_unlink(tmp_path);
    g_free(tmp_path);
    return pixbuf;
}

static GdkPixbuf *load_and_crop_image(const char *path) {
    int w = 0, h = 0;
    if (!gdk_pixbuf_get_file_info(path, &w, &h)) return NULL;
    if (w <= 0 || h <= 0) return NULL;
    
    int target_w = 256;
    int target_h = 256;
    if (w > h) {
        target_w = -1; /* Scale height to 256, let width be proportional */
    } else {
        target_h = -1; /* Scale width to 256, let height be proportional */
    }
    
    GError *err = NULL;
    GdkPixbuf *scaled = gdk_pixbuf_new_from_file_at_scale(path, target_w, target_h, TRUE, &err);
    if (!scaled) {
        if (err) g_error_free(err);
        return NULL;
    }
    
    int sw = gdk_pixbuf_get_width(scaled);
    int sh = gdk_pixbuf_get_height(scaled);
    
    int size = MIN(sw, sh);
    int x = MAX(0, (sw - size) / 2);
    int y = MAX(0, (sh - size) / 2);
    
    GdkPixbuf *sub = gdk_pixbuf_new_subpixbuf(scaled, x, y, size, size);
    GdkPixbuf *final = gdk_pixbuf_copy(sub);
    g_object_unref(sub);
    g_object_unref(scaled);
    
    return final;
}

// Generates a thumbnail for a given file URI (image/video) and returns the cached path.
// Returns dynamically allocated string (must be freed by caller using free_string_ffi).
const char* generate_thumbnail_ffi(const char* uri, const char* mime_type) {
    if (!uri) return NULL;
    
    char *thumb_path = get_thumbnail_path(uri);
    
    // 1. Check if cached
    if (g_file_test(thumb_path, G_FILE_TEST_EXISTS)) {
        return thumb_path; // Caller must free this string
    }
    
    // 2. Generate if not cached
    GdkPixbuf *pixbuf = NULL;
    char *local_path = g_filename_from_uri(uri, NULL, NULL);
    if (local_path) {
        if (mime_type && g_str_has_prefix(mime_type, "video/")) {
            pixbuf = generate_video_thumbnail(local_path);
        } else {
            // Default to image thumbnail
            pixbuf = load_and_crop_image(local_path);
        }
        g_free(local_path);
    }
    
    if (pixbuf) {
        // Save to cache
        gdk_pixbuf_save(pixbuf, thumb_path, "png", NULL, "tEXt::Thumb::URI", uri, NULL);
        g_object_unref(pixbuf);
        return thumb_path; // Caller must free this string
    }
    
    g_free(thumb_path);
    return NULL;
}

const char* get_thumbnail_path_ffi(const char* uri) {
    if (!uri) return NULL;
    return get_thumbnail_path(uri);
}

int get_image_dimensions_ffi(const char* path, int* width, int* height) {
    if (!path || !width || !height) return 0;
    int w = 0, h = 0;
    if (gdk_pixbuf_get_file_info(path, &w, &h)) {
        *width = w;
        *height = h;
        return 1;
    }
    return 0;
}

void free_string_ffi(const char* ptr) {
    if (ptr) {
        g_free((gpointer)ptr);
    }
}

#ifdef __cplusplus
}
#endif
