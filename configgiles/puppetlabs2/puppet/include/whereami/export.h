
#ifndef LIBWHEREAMI_EXPORT_H
#define LIBWHEREAMI_EXPORT_H

#ifdef LIBWHEREAMI_STATIC_DEFINE
#  define LIBWHEREAMI_EXPORT
#  define LIBWHEREAMI_NO_EXPORT
#else
#  ifndef LIBWHEREAMI_EXPORT
#    ifdef libwhereami_EXPORTS
        /* We are building this library */
#      define LIBWHEREAMI_EXPORT 
#    else
        /* We are using this library */
#      define LIBWHEREAMI_EXPORT 
#    endif
#  endif

#  ifndef LIBWHEREAMI_NO_EXPORT
#    define LIBWHEREAMI_NO_EXPORT 
#  endif
#endif

#ifndef LIBWHEREAMI_DEPRECATED
#  define LIBWHEREAMI_DEPRECATED 
#endif

#ifndef LIBWHEREAMI_DEPRECATED_EXPORT
#  define LIBWHEREAMI_DEPRECATED_EXPORT LIBWHEREAMI_EXPORT LIBWHEREAMI_DEPRECATED
#endif

#ifndef LIBWHEREAMI_DEPRECATED_NO_EXPORT
#  define LIBWHEREAMI_DEPRECATED_NO_EXPORT LIBWHEREAMI_NO_EXPORT LIBWHEREAMI_DEPRECATED
#endif

#define DEFINE_NO_DEPRECATED 0
#if DEFINE_NO_DEPRECATED
# define LIBWHEREAMI_NO_DEPRECATED
#endif

#endif