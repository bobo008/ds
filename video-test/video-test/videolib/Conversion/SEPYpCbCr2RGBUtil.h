
#import <UIKit/UIKit.h>
#import <simd/simd.h>

#ifdef __cplusplus
extern "C" {
#endif

extern const float * kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_videoRange_Matrix;
extern const float * kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_videoRange_Bias;

extern const float * kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_fullRange_Matrix;
extern const float * kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_fullRange_Bias;

extern const float * kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_videoRange_Matrix;
extern const float * kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_videoRange_Bias;

extern const float * kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_fullRange_Matrix;
extern const float * kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_fullRange_Bias;

extern const float * kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_videoRange_Matrix;
extern const float * kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_videoRange_Bias;

extern const float * kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_fullRange_Matrix;
extern const float * kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_fullRange_Bias;

extern const float * kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_videoRange_Matrix;
extern const float * kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_videoRange_Bias;

extern const float * kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_fullRange_Matrix;
extern const float * kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_fullRange_Bias;

BOOL SEPAutoSelectConversion(CVPixelBufferRef YUVPixel, const float **outMatrix, const float **outBias);

#ifdef __cplusplus
}
#endif
