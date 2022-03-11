/*!
 *   @file       iSmartDebugKitARCSupport.h
 *   @date       10/12/12.
 *   @author     Siarhei Ladzeika
 *   @version    1.0
 *  @internal
 *  @brief      Internal use only!
 */

#ifndef iSmartDebugKitDemo_iSmartDebugKitARCSupport_h
#define iSmartDebugKitDemo_iSmartDebugKitARCSupport_h


#if !defined(__clang__) || __clang_major__ < 3 || !__has_feature(objc_arc)

    #define iSmartDebugKit_uses_arc     0

    #ifndef iSmartDebugKit__bridge
    #define iSmartDebugKit__bridge
    #endif

    #ifndef iSmartDebugKit__bridge_retain
    #define iSmartDebugKit__bridge_retain
    #endif

    #ifndef iSmartDebugKit__bridge_retained
    #define iSmartDebugKit__bridge_retained
    #endif

    #ifndef iSmartDebugKit__autoreleasing
    #define iSmartDebugKit__autoreleasing
    #endif

    #ifndef iSmartDebugKit__strong
    #define iSmartDebugKit__strong
    #endif

    #ifndef iSmartDebugKit__unsafe_unretained
    #define iSmartDebugKit__unsafe_unretained
    #endif

    #ifndef iSmartDebugKit__weak
    #define iSmartDebugKit__weak
    #endif

#else

    #define iSmartDebugKit_uses_arc     1

    #ifndef iSmartDebugKit__bridge
    #define iSmartDebugKit__bridge              __bridge
    #endif

    #ifndef iSmartDebugKit__bridge_retain
    #define iSmartDebugKit__bridge_retain       __bridge_retain
    #endif

    #ifndef iSmartDebugKit__bridge_retained
    #define iSmartDebugKit__bridge_retained     __bridge_retained
    #endif

    #ifndef iSmartDebugKit__autoreleasing
    #define iSmartDebugKit__autoreleasing       __autoreleasing
    #endif

    #ifndef iSmartDebugKit__strong
    #define iSmartDebugKit__strong              __strong
    #endif

    #ifndef iSmartDebugKit__unsafe_unretained
    #define iSmartDebugKit__unsafe_unretained   __unsafe_unretained
    #endif

    #ifndef iSmartDebugKit__weak
    #define iSmartDebugKit__weak                __weak
    #endif

#endif

#if __has_feature(objc_arc)
# define iSmartDebugKit_ARC_PROP_RETAIN strong
# define iSmartDebugKit_ARC_RETAIN(x) (x)
# define iSmartDebugKit_ARC_RETAIN_AUTORELEASE(x) (x)
# define iSmartDebugKit_ARC_RELEASE(x)
# define iSmartDebugKit_ARC_AUTORELEASE(x) (x)
# define iSmartDebugKit_ARC_AUTORELEASE_NO_RET(x) (void)(x)
# define iSmartDebugKit_ARC_BLOCK_COPY(x) ([x copy])
# define iSmartDebugKit_ARC_BLOCK_RELEASE(x)
# define iSmartDebugKit_ARC_SUPER_DEALLOC()
#else
# define iSmartDebugKit_ARC_PROP_RETAIN retain
# define iSmartDebugKit_ARC_RETAIN(x) ([(x) retain])
# define iSmartDebugKit_ARC_RETAIN_AUTORELEASE(x) ([[(x) retain] autorelease])
# define iSmartDebugKit_ARC_RELEASE(x) ([(x) release])
# define iSmartDebugKit_ARC_AUTORELEASE(x) ([(x) autorelease])
# define iSmartDebugKit_ARC_AUTORELEASE_NO_RET(x) ([(x) autorelease])
# define iSmartDebugKit_ARC_BLOCK_COPY(x) (Block_copy(x))
# define iSmartDebugKit_ARC_BLOCK_RELEASE(x) (Block_release(x))
# define iSmartDebugKit_ARC_SUPER_DEALLOC() ([super dealloc])
#endif



#endif
