---
title: "Automate Resizing Bulk Images Using Libvips"
date: 2021-08-28T19:09:03+07:00
draft: true
---

With the growing popularity of ShopeeFood, many restaurants were applying for partnership with them, included my relative's Padang restaurant. But, their registration was not easy. They need a photo for each menu to be in a format of 720x720 px. For a Padang restaurant with over 50 menus and unfortunately the restaurant's menu photos were in different sizes.  

I was too lazy to resized them manually. At first, I search for a service that could resize an image. But they weren't able to resize so many images at once. So I thought to write a program to automate this.
Enter the libvips, libvips was a software that was used for image manipulation. Since I used Go and libvips was written in C, I searched for a Go libvips package and found [bimg](https://github.com/h2non/bimg).

The code was pretty simple, we only need to iterate all of the photos in a directory. Then, for each of photo, resize it into 720x720 px. But, because the photos are not all squares, we can't use the `Resize` method instead, we use `ResizeAndCrop` that will resize the photos into 720x720 px and crop it fill to center
```go
import (
    "fmt"
	"path"

	"github.com/h2non/bimg"
)

var root = "/menu-photos"
var outdir = "/menu-photos/720x720"

func resize(filepath, filename string) error {
	buf, err := bimg.Read(filepath)
	if err != nil {
		return err
	}

	img := bimg.NewImage(buf)
	size, err := img.Size()
	if err != nil {
		return err
	}

	newImage, err := img.ResizeAndCrop(720, 720)
	if err != nil {
        return err
	}

	size, err = bimg.NewImage(newImage).Size()
	if err != nil {
		return err
	}

	if size.Width != 720 || size.Height != 720 {
		fmt.Printf("wrong size: '%s' %vx%v\n", filename, size.Width, size.Height)
	}

	fmt.Printf("resize & crop: %s\n", filename)
	return bimg.Write(path.Join(outdir, filename), newImage)
}
```