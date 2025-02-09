#include <opencv2/opencv.hpp>
#include <chrono>

#ifdef __ANDROID__
#include <android/log.h>
#endif

using namespace cv;
using namespace std;

extern "C"
{

    void platform_log(const char *fmt, ...)
    {
        va_list args;
        va_start(args, fmt);
#ifdef __ANDROID__
        __android_log_vprint(ANDROID_LOG_VERBOSE, "FFI Logger: ", fmt, args);
#else
        vprintf(fmt, args);
#endif
        va_end(args);
    }

    __attribute__((visibility("default"))) __attribute__((used))
    const char *
    getOpenCVVersion()
    {
        return CV_VERSION;
    }

    __attribute__((visibility("default"))) __attribute__((used)) 
    void convertImageToGrayImage(const char *inputImagePath, const char *outputPath)
    {
        platform_log("PATH %s: ", inputImagePath);
        
        // Load the image
        cv::Mat img = cv::imread(inputImagePath);
        if (img.empty())
        {
            platform_log("Error: Could not load image from file: %s", inputImagePath);
            return;
        }
        platform_log("Image loaded successfully. Dimensions: %d x %d", img.rows, img.cols);
    
        // Convert to grayscale
        cv::Mat graymat;
        cv::cvtColor(img, graymat, cv::COLOR_BGR2GRAY);
    
        // Remove the existing file if it exists
        if (std::remove(outputPath) == 0)
        {
            platform_log("Existing file deleted: %s", outputPath);
        }
        else
        {
            platform_log("No existing file found or unable to delete: %s", outputPath);
        }
    
        // Write the new grayscale image
        if (cv::imwrite(outputPath, graymat))
        {
            platform_log("Gray image saved successfully. Dimensions: %d x %d", graymat.rows, graymat.cols);
        }
        else
        {
            platform_log("Error: Failed to write the image to file: %s", outputPath);
        }
    }

    __attribute__((visibility("default"))) __attribute__((used)) 
    void convertImageToBlurImage(char *inputImagePath, char *outputPath)
    {
        platform_log("Input Image Path: %s", inputImagePath);

        cv::Mat image = cv::imread(inputImagePath);
        if (image.empty())
        {
            platform_log("Error: Could not load image from file: %s", inputImagePath);
            return;
        }
        platform_log("Image loaded successfully. Dimensions: %d x %d", image.rows, image.cols);

        cv::Mat blurredImage;
        cv::GaussianBlur(image, blurredImage, cv::Size(51, 51), 0);
        cv::imwrite(outputPath, blurredImage);

        platform_log("Blurred image saved successfully. Dimensions: %d x %d", blurredImage.rows, blurredImage.cols);
    }

    __attribute__((visibility("default"))) __attribute__((used)) 
    void convertImageToSharpenImage(char *inputImagePath, char *outputPath)
    {
        platform_log("Input Image Path: %s", inputImagePath);

        cv::Mat image = cv::imread(inputImagePath);
        if (image.empty())
        {
            platform_log("Error: Could not load image from file: %s", inputImagePath);
            return;
        }
        platform_log("Image loaded successfully. Dimensions: %d x %d", image.rows, image.cols);

        cv::Mat kernel = (cv::Mat_<float>(3, 3) <<
                          0, -1, 0,
                          -1, 5, -1,
                          0, -1, 0);

        cv::Mat sharpenedImage;
        cv::filter2D(image, sharpenedImage, -1, kernel);
        cv::imwrite(outputPath, sharpenedImage);

        platform_log("Sharpened image saved successfully. Dimensions: %d x %d", sharpenedImage.rows, sharpenedImage.cols);
    }

    __attribute__((visibility("default"))) __attribute__((used)) 
    void convertImageToEdgeImage(char *inputImagePath, char *outputPath)
    {
        platform_log("Input Image Path: %s", inputImagePath);

        cv::Mat image = cv::imread(inputImagePath, cv::IMREAD_GRAYSCALE);
        if (image.empty())
        {
            platform_log("Error: Could not load image from file: %s", inputImagePath);
            return;
        }
        platform_log("Image loaded successfully. Dimensions: %d x %d", image.rows, image.cols);

        cv::Mat blurredImage;
        cv::GaussianBlur(image, blurredImage, cv::Size(5, 5), 0);

        cv::Mat edges;
        cv::Canny(blurredImage, edges, 50, 150);
        cv::imwrite(outputPath, edges);

        platform_log("Edge-detected image saved successfully. Dimensions: %d x %d", edges.rows, edges.cols);
    }
}
