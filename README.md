 
This project was created based on the requirements of Coursera: iOS App Development Basics - course 2 of the Swift Specialization: https://www.coursera.org/specializations/app-development.

This project was written in Swift 2 in xCode 7.3.1 as a requirement of the course initially. This project was created as Single View Application. This project was upgraded to XCODE 9.3.1.

In this app, the user can select an image from the album or from the camera. Tapping on the “Filter” button will display a scroll view of multiple image filters. The user then selects a filter to be applied to the chosen image. After the filter is completed, tapping on the “Edit” button will activate a slider control, which can be used used to adjust the light intensity of the filtered image. Press-and-hold on the filtered image will show the original image; when let go, the filtered image will be displayed again. Tapping the “Compare” button will also toggle between the original image and the filtered image. Image can be shared via “Share” button.

The image filter is applied pixel per pixel as specified in Week 4 of Course 1 – “Introduction to Swift”. This method is to demonstrate pixel manipulation and it is also not very efficient for a large image. Hence, an activity control is activated when an image filter is applying to indicate to the user the app is busy.
