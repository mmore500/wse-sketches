import colorsys
import random
import typing


# adapted from https://github.com/mmore500/hstrat-recomb-concept/blob/b71d36216f1d2990343b6435240d8c193a82690b/pylib/util/val_to_color.py
def val_to_color(
    val: typing.Any, saturation: float = 1.0, brightness: float = 0.5
) -> typing.Tuple[int, int, int]:
    # Convert the hash to a value between 0 and 1
    rand = random.Random()
    rand.seed(str(val))
    hue = rand.random()

    # Convert the HSV color to an RGB color
    rgb_color = colorsys.hsv_to_rgb(hue, saturation, brightness)

    # Convert RGB values into 0-255 range (suitable for use in digital color)
    rgb_color_255 = tuple(int(c * 255) for c in rgb_color)

    return rgb_color_255
