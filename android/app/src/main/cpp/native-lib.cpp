#include <jni.h>
#include <string>

#include<opencv2/opencv.hpp>
#include<iostream>
#include <opencv2/imgproc/types_c.h>
//#include <opencv2/highgui/highgui.hpp>
//#include <opencv2/core/core.hpp>
//#include <opencv2/imgproc/imgproc.hpp>
#include <unistd.h>
#include <android/bitmap.h>

#include <android/log.h>
#define TAG "native-lib.cpp" // 这个是自定义的LOG的标识
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG,TAG ,__VA_ARGS__) // 定义LOGD类型
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,TAG ,__VA_ARGS__) // 定义LOGI类型
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN,TAG ,__VA_ARGS__) // 定义LOGW类型
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR,TAG ,__VA_ARGS__) // 定义LOGE类型
#define LOGF(...) __android_log_print(ANDROID_LOG_FATAL,TAG ,__VA_ARGS__) // 定义LOGF类型
//char * name = "mronion";
//LOGD("my name is %s\n", name );

using namespace cv;
using namespace std;

extern "C" int32_t
native_add(int32_t x, int32_t y) {
    return x + y;
}

void free_string(char *str)
{
    // Free native memory in C which was allocated in C.
    free(str);
}

extern "C" char *
opencv_version() {
    //return "Hello from Native\0";
    //char * name = "aaa123";
    LOGD("opencv ver. %s\n", CV_VERSION );
    //return name;

    char * v;
    v = (char *)malloc(10);
    strcpy(v,CV_VERSION);
    return v;
}

/*
//定义IntArray结构体
typedef struct {
    int32_t *data;
    int32_t length;
} IntArray;

extern "C" IntArray *
bitmap2Gray(const int32_t *intArray, int32_t length, int w,int h){

    int ret[w*h];

    Mat img(h, w, CV_8UC4, pixels);

    cvtColor(img, img, CV_BGRA2GRAY);
    cvtColor(img, img, CV_GRAY2BGRA);
}
*/


extern "C" JNIEXPORT jstring JNICALL
Java_com_example_android_1opencv_1mobile_MainActivity_stringFromJNI(
        JNIEnv* env,
        jobject /* this */) {
    std::string hello = "OpenCV ver." CV_VERSION;
    return env->NewStringUTF(hello.c_str());
}


extern "C" JNIEXPORT jintArray JNICALL
Java_com_example_android_1opencv_1mobile_MainActivity_bitmap2Gray(JNIEnv *env, jobject instance, jintArray pixels, jint w, jint h) {
    jint *cur_array;

    jboolean isCopy = static_cast<jboolean> (false);

    cur_array = env-> GetIntArrayElements(pixels, &isCopy);
    if (cur_array == NULL) {
        return 0;
    }

    Mat img(h, w, CV_8UC4, (unsigned char *) cur_array);

    cvtColor(img, img, CV_BGRA2GRAY);
    cvtColor(img, img, CV_GRAY2BGRA);

    int size = w * h;
    jintArray result = env->NewIntArray(size);
    env-> SetIntArrayRegion(result, 0, size, (jint *) img.data);
    env-> ReleaseIntArrayElements(pixels, cur_array, 0);
    return result;
}



extern "C" JNIEXPORT void JNICALL
Java_com_example_android_1opencv_1mobile_MainActivity_bitmap2GaussianBlur(JNIEnv *env, jobject instance, jobject bmp) {
    AndroidBitmapInfo info;
    void *pixels;

    CV_Assert(AndroidBitmap_getInfo(env, bmp, &info) >= 0);
    //判断图片是位图格式有RGB_565 、RGBA_8888
    CV_Assert(info.format == ANDROID_BITMAP_FORMAT_RGBA_8888 ||
              info.format == ANDROID_BITMAP_FORMAT_RGB_565);
    CV_Assert(AndroidBitmap_lockPixels(env, bmp, &pixels) >= 0);
    CV_Assert(pixels);

    //将bitmap转化为Mat类
    Mat img(info.height, info.width, CV_8UC4, pixels);

    //均值模糊
    //Size(w,h)的宽w高h只能是基数
    // blur(image,image,Size(101,101),Point(-1,-1));
    // 高斯模糊
    GaussianBlur(img, img, Size(151, 151), 151);
}


extern "C" JNIEXPORT jintArray JNICALL
Java_com_example_android_1opencv_1mobile_MainActivity_bitmap2Threshold(JNIEnv *env, jobject instance, jintArray pixels, jint w, jint h) {
    jint *cur_array;

    jboolean isCopy = static_cast<jboolean> (false);

    cur_array = env-> GetIntArrayElements(pixels, &isCopy);
    if (cur_array == NULL) {
        return 0;
    }

    Mat img(h, w, CV_8UC4, (unsigned char *) cur_array);
    Mat ret = img.clone();
    //进行二值化处理，选择30，200.0为阈值
    threshold(img, ret, 30, 200.0, CV_THRESH_BINARY);




    int size = w * h;
    jintArray result = env->NewIntArray(size);
    env-> SetIntArrayRegion(result, 0, size, (jint *) ret.data);
    env-> ReleaseIntArrayElements(pixels, cur_array, 0);
    return result;
}



