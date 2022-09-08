
#import "SEPYpCbCr2RGBUtil.h"

#ifdef DEBUG
#define NSLog(FORMAT, ...) (fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]));
#else
#define NSLog(...) {}
#endif

const float kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_videoRange_Matrix_[] = {
    1.164384, 1.164384, 1.164384,
    0.000000, -0.213249, 2.112402,
    1.792741, -0.532909, 0.000000
};
const float kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_videoRange_Bias_[] = {
    0.062745, 0.501961, 0.501961
};

const float kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_fullRange_Matrix_[] = {
    1.000000, 1.000000, 1.000000,
    0.000000, -0.188062, 1.862906,
    1.581000, -0.469967, 0.000000
};
const float kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_fullRange_Bias_[] = {
    0.000000, 0.501961, 0.501961
};

const float kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_videoRange_Matrix_[] = {
    1.164384, 1.164384, 1.164384,
    0.000000, -0.391762, 2.017232,
    1.596027, -0.812968, 0.000000
};
const float kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_videoRange_Bias_[] = {
    0.062745, 0.501961, 0.501961
};

const float kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_fullRange_Matrix_[] = {
    1.000000, 1.000000, 1.000000,
    0.000000, -0.345491, 1.778976,
    1.407520, -0.716948, 0.000000
};
const float kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_fullRange_Bias_[] = {
    0.000000, 0.501961, 0.501961
};

const float kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_videoRange_Matrix_[] = {
    1.164384, 1.164384, 1.164384,
    0.000000, -0.187326, 2.141772,
    1.678674, -0.650424, 0.000000
};
const float kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_videoRange_Bias_[] = {
    0.062745, 0.501961, 0.501961
};

const float kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_fullRange_Matrix_[] = {
    1.000000, 1.000000, 1.000000,
    0.000000, -0.165201, 1.888807,
    1.480406, -0.573603, 0.000000
};
const float kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_fullRange_Bias_[] = {
    0.000000, 0.501961, 0.501961
};

const float kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_videoRange_Matrix_[] = {
    1.167808, 1.167808, 1.167808,
    0.000000, -0.187877, 2.148072,
    1.683611, -0.652337, 0.000000
};
const float kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_videoRange_Bias_[] = {
    0.062561, 0.500489, 0.500489
};

const float kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_fullRange_Matrix_[] = {
    1.000000, 1.000000, 1.000000,
    0.000000, -0.164714, 1.883241,
    1.476043, -0.571912, 0.000000
};
const float kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_fullRange_Bias_[] = {
    0.000000, 0.500489, 0.500489
};

const float * kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_videoRange_Matrix = kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_videoRange_Matrix_;
const float * kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_videoRange_Bias = kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_videoRange_Bias_;

const float * kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_fullRange_Matrix = kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_fullRange_Matrix_;
const float * kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_fullRange_Bias = kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_fullRange_Bias_;

const float * kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_videoRange_Matrix = kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_videoRange_Matrix_;
const float * kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_videoRange_Bias = kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_videoRange_Bias_;

const float * kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_fullRange_Matrix = kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_fullRange_Matrix_;
const float * kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_fullRange_Bias = kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_fullRange_Bias_;

const float * kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_videoRange_Matrix = kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_videoRange_Matrix_;
const float * kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_videoRange_Bias = kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_videoRange_Bias_;

const float * kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_fullRange_Matrix = kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_fullRange_Matrix_;
const float * kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_fullRange_Bias = kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_fullRange_Bias_;

const float * kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_videoRange_Matrix = kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_videoRange_Matrix_;
const float * kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_videoRange_Bias = kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_videoRange_Bias_;

const float * kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_fullRange_Matrix = kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_fullRange_Matrix_;
const float * kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_fullRange_Bias = kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_fullRange_Bias_;

BOOL SEPAutoSelectConversion(CVPixelBufferRef YUVPixel, const float **outMatrix, const float **outBias) {
    const GLfloat *colorConversionMatrix;
    const GLfloat *colorConversionBias;
    
    const OSType pixelFormat = CVPixelBufferGetPixelFormatType(YUVPixel);
    const CFTypeRef attachment_YCbCrMatrix = CVBufferGetAttachment(YUVPixel, kCVImageBufferYCbCrMatrixKey, NULL);
    if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        colorConversionMatrix = kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_videoRange_Matrix;
        colorConversionBias = kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_videoRange_Bias;
        if (attachment_YCbCrMatrix) {
            if (CFStringCompare(attachment_YCbCrMatrix, kCVImageBufferYCbCrMatrix_ITU_R_2020, 0) == kCFCompareEqualTo) {
                colorConversionMatrix = kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_videoRange_Matrix;
                colorConversionBias = kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_videoRange_Bias;
            } else if (CFStringCompare(attachment_YCbCrMatrix, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
                colorConversionMatrix = kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_videoRange_Matrix;
                colorConversionBias = kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_videoRange_Bias;
            }
        }
    } else if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
        colorConversionMatrix = kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_fullRange_Matrix;
        colorConversionBias = kSEP_YpCbCr2RGB_ITU_R_709_2_8Bit_fullRange_Bias;
        if (attachment_YCbCrMatrix) {
            if (CFStringCompare(attachment_YCbCrMatrix, kCVImageBufferYCbCrMatrix_ITU_R_2020, 0) == kCFCompareEqualTo) {
                colorConversionMatrix = kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_fullRange_Matrix;
                colorConversionBias = kSEP_YpCbCr2RGB_ITU_R_2020_8Bit_fullRange_Bias;
            } else if (CFStringCompare(attachment_YCbCrMatrix, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
                colorConversionMatrix = kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_fullRange_Matrix;
                colorConversionBias = kSEP_YpCbCr2RGB_ITU_R_601_4_8Bit_fullRange_Bias;
            }
        }
    } else if (pixelFormat == kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange) {
        if (attachment_YCbCrMatrix) {
            assert(CFStringCompare(attachment_YCbCrMatrix, kCVImageBufferYCbCrMatrix_ITU_R_2020, 0) == kCFCompareEqualTo);
        }
        colorConversionMatrix = kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_videoRange_Matrix;
        colorConversionBias = kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_videoRange_Bias;
    } else if (pixelFormat == kCVPixelFormatType_420YpCbCr10BiPlanarFullRange) {
        if (attachment_YCbCrMatrix) {
            assert(CFStringCompare(attachment_YCbCrMatrix, kCVImageBufferYCbCrMatrix_ITU_R_2020, 0) == kCFCompareEqualTo);
        }
        colorConversionMatrix = kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_fullRange_Matrix;
        colorConversionBias = kSEP_YpCbCr2RGB_ITU_R_2020_10Bit_fullRange_Bias;
    } else {
        return NO;
    }
    
    *outMatrix = colorConversionMatrix;
    *outBias = colorConversionBias;
    return YES;
}
