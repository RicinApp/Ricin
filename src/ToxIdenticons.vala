/**
* COPYRIGHT (c) 2016 SkyzohKey & Benwaffle
*
* MIT License
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
* LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
* OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
* WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**/
/**
* The original algorithm used in this file is from identicon.js by stewartlord.
* @page https://github.com/stewartlord/identicon.js
* Copyright (c) 2013, Stewart Lord
* All rights reserved.
**/

using Cairo;

namespace ToxIdenticon {
  struct RGB {
    double red;
    double green;
    double blue;
  }

  class Utils : Object {
    public static RGB hsl2rgb (double h, double s, double b) {
      h *= 6;
      double hsl[] = {
        b += s *= b < 0.5 ? b : 1 - b,
        b - h % 1 * s * 2,
        b -= s *= 2,
        b,
        b + h % 1 * s,
        b + s
      };

      return RGB () {
        red = hsl[ (int)h % 6 ],
        green = hsl[ ((int)h|16) % 6 ],
        blue = hsl[ ((int)h|8) % 6 ]
      };
    }

    public static int parse_base16 (string? s) {
      if (s == null)
        return 0;
      int res;
      s.scanf ("%x", out res);
      return res;
    }
  }

  class ToxIdenticon : Object {
    private ImageSurface surface;
    private Context context;
    private bool has_custom_context = false;

    public string hash { get; set; }
    public string salt { get; set; default = ""; }
    public double margin { get; set; default = 0.08; }
    public int size { get; set; default = 48; }
    public bool stroke { get; set; default = true; }

    public ToxIdenticon () {
      this.surface = new ImageSurface (Format.ARGB32, this.size, this.size);
      this.context = new Context (this.surface);
    }

    /**
    * TODO
    * FIXME: Makes the final identicon blank.
    **/
    public ToxIdenticon.with_context (Context context) {
      this.context = context;
      this.surface = (ImageSurface) this.context.get_target ();
      this.has_custom_context = true;
    }

    private void init_surface () {
      if (this.has_custom_context == false) {
        this.surface = new ImageSurface (Format.ARGB32, this.size, this.size);
        this.context = new Context (this.surface);
      }
    }

    private void draw_rect (double x, double y, double width, double height, RGB color, bool isEven) {
      this.context.set_source_rgba (color.red, color.green, color.blue, 1);
      this.context.rectangle (x, y, width, height);
      this.context.fill ();

      if (this.stroke && isEven) {
        this.context.set_source_rgba (140, 140, 140, 0.5);
        this.context.rectangle (x, y, width, height);
        this.context.stroke ();
      }
    }

    private void render () {
      var hash = Checksum.compute_for_string (ChecksumType.SHA512, this.hash + this.salt);
      var size = this.size;
      var baseMargin = Math.floor(size * this.margin);
      var cell = Math.floor((size - (baseMargin * 2)) / 5);
      var margin = Math.floor((size - cell * 5) / 2);

      // Background color
      var background = RGB () {
        red = 240.0/255,
        green = 240.0/255,
        blue = 240.0/255
      };
      this.draw_rect (0, 0, this.size, this.size, background, false);

      // Foreground color
      var foreground = Utils.hsl2rgb ((double) Utils.parse_base16 (hash.substring (-7)) / 0xfffffff, 0.5, 0.7);

      // The first 15 characters of the hash control the pixels (even/odd)
      // they are drawn down the middle first, then mirrored outwards
      for (var i = 0; i < 15; i++) {
        var color = (Utils.parse_base16 ("%c".printf (hash[i])) % 2) != 0 ? background : foreground;
        var isEven = (color == foreground);
        if (i < 5) {
          this.draw_rect (2 * cell + margin, i * cell + margin, cell, cell, color, isEven);
        } else if (i < 10) {
          this.draw_rect (1 * cell + margin, (i - 5) * cell + margin, cell, cell, color, isEven);
          this.draw_rect (3 * cell + margin, (i - 5) * cell + margin, cell, cell, color, isEven);
        } else if (i < 15) {
          this.draw_rect (0 * cell + margin, (i - 10) * cell + margin, cell, cell, color, isEven);
          this.draw_rect (4 * cell + margin, (i - 10) * cell + margin, cell, cell, color, isEven);
        }
      }
    }

    public Surface generate (int size, string hash, string salt = "") {
      this.size = size;
      this.hash = hash;
      this.salt = salt;

      this.init_surface ();
      this.render ();
      this.context.save ();

      return this.surface;
    }
  }
}
