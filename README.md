# PhotoKitBug
Project to demonstrate bug in PhotoKit

This bug was reported to Apple as [rdar://25181601](https://openradar.appspot.com/25181601).

## Summary
When using `PHImageManager` or `PHCachingImageManager` to request large images using the `PHImageRequestOptionsDeliveryMode.Opportunistic` option the first (low quality) image that is returned is not the largest image that is currently available on the device.

## Description
If you request an image using `PHImageManager.requestImageForAsset(_:targetSize:contentMode:options:resultHandler:)` 
with the option `PHImageRequestOptionsDeliveryMode.Opportunistic` and a targetSize of *up to* 256x256, PhotoKit first returns a tiny (60x45) thumbnail and almost instantly afterwards returns the largest thumbnail currently available on device (without needing to download anything from iCloud). These are typically 342x256 images.

However, if you make exactly the same request with a larger targetSize (eg 512x512), PhotoKit also first returns the tiny 60x45 thumbnail, but it then waits until it can obtain the full size image from iCloud Photo Library, even though the largest on device image is 342x256. This can be proven by using the `networkAccessAllowed` option set to `false`. With this option and a 256x256 targetSize, the larger (342x256) thumbnail is still returned so it must be available on the device.

Even on the Simulator this effect can be seen although here when requesting 512x512 the full size image is eventually returned as it is stored on disk.

When using the Opportunistic option, and a large targetSize, PhotoKit should always return the largest available image currently on the device before trying to download a larger image from iCloud Photo Library.

Steps to Reproduce:
**Note:** the ideal setup for demonstrating the problem is an iOS Device with iCloud Photo Library enabled with "Optimize Storage" option such that only thumbnails are stored on the device, not full size photos. The problem can be demonstrated on the iOS Simulator, but not so well.

1. Build and run the PhotoKitBug app on the test device from Xcode (so you can see the debug console output).
2. When prompted at app startup, Allow the app access to Photos.
3. Tap the 256x256 button in the top left corner.
4. The debug console will show that a 60x45 image is loaded and then almost immediately afterwards, a larger 342x256 image.
5. Now tap the 512x512 button in the top right corner.
6. The debug console shows the 60x45 thumbnail is loaded first, and then no larger image is ever loaded (if you are running on a device with iCloud Photo Library enabled as mentioned above). We are using `networkAccessAllowed = false`. If you are running on the simulator, the full size image is eventually loaded after a delay of a second or so, but you will still note that the 342x256 thumbnail loaded when the smaller image was requested is never provided as an intermediate.
