## How to Use

1. If you haven't yet, download Flight of the Amazon Queen from [ScummVM's website](https://scummvm.org/games/#games-queen:queen).
2. Use [Sparky](https://forums.scummvm.org/viewtopic.php?p=22627&sid=ea8f0fbce26e5526acb02b548622d94d#p22627) to unpack your `queen.1` file. Or `queen.1c`. It doesn't seem to work with all queen files provided by ScummVM.
3. Download (or build) and run this tool. You can find the download by clicking released on the right side of this GitHub page.
4. Open a PCX background image. The tool gets the palette from this file by reading the last 768 bytes only. It will not read anything else, including the header.
5. Open an ACT, BBK or SAM sprite file. 
6. If the result looks odd, you have the wrong palette. Select another PCX file from the leftmost list. There are some sprites that will only work with very specific PCX palettes, e.g `ANDSON_E.ACT` will only work with `E1.pcx`.

![image](https://github.com/user-attachments/assets/1b480000-b86e-4fc1-b04c-5bedca6cd299)
(Picture says editor, but it's a viewer.)

## How to Build

Open `.dpr` in Delphi (e.g. the free Community Edition) and press <kbd>F9</kbd>.


## What Are These Files?

PCX are standard image files that pretty much any image viewer and editor (or even MS Paint on Windows 98!) will load. Some are portraits. The others use a naming pattern:

- **B**ob's
- **C**rash Site
- **D**emo
- **E**xtro
- **F**ortress of the Amazons
- **I**ntro
- **J**ungle
- **M**ountain Peak
- **N**azi "Lederhosen Factory"
- **R**ocket Comic Strip
- **T**emple
- **V**alley of the Mists
- **X**tra Intro

Queen's proprietary ACT, BBK and SAM file formats are all exactly the same. You can try to identify some pattern in the extensions they used, but in the end, use of these extensions are basically random.

- BBK: Animated parts of the backdrop. Many have the background file's name.
- ACT (Actors): Characters etc., used in cutscenes, but it also contains the keypad skull of the Amazon retreat (`SKULL.ACT`).
- SAM (Special Animations): where people don't talk but still do things, so mostly Joe.

Oftentimes, multiple related animations are in the same file.


## What Is This File Format?

- Header:
  - 1 word - item count
- For each item:
  - 1 word - width
  - 1 word - height
  - 1 word - X hotspot
  - 1 word - Y hotspot
  - `width * height` bytes - Image data (8BPP, left to right, top to bottom) - `0x00` is transparent
 

## Fun Facts

- The third list from the left doesn't have any events.
- This tool uses a very simple GIF/LZW encoder that creates a so-called [uncompressed GIF](https://en.wikipedia.org/wiki/GIF#Uncompressed_GIF) which is then loaded by Delphi's GIF component. When you save the GIF to a file, it asks this component to save the loaded GIF. This will compress it.
- I made this when I considered porting Flight of the Amazon Queen to Game Boy Color. This would be absolutely insane given the harsh limitations of this platform. FOTAQ's creators actually [wanted to release the game for the original Game Boy](https://passfieldgames.blogspot.com/2015/05/making-of-flight-of-amazon-queen-20th.html), but this was not a port.
