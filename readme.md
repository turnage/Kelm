# Kelm

A set of simple reference implementations.

## How do I use Kelm?

Really, just look at it. My implementations meet test vectors, but they are slow
and pay no attention to side channel attacks or the like. I intend for people to
refer to it when studying and learning the algorithms it implements, because the
code is simple and self documenting.

## Can I build Kelm?

Kelm isn't intended for field use, but for educational purposes. It can still
be used in programs however. Allow the source files to be seen by your program
and use

    with kelm.____;

where ____ is the module you want to use.

## Is Kelm licensed?

Copyright (c) 2013, Payton Turnage <paytonturnage@gmail.com>

Permission to use, copy, modify, and/or distribute this software for any purpose
with or without fee is hereby granted, provided that the above copyright notice
and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
THIS SOFTWARE.

## Contribution

I'm not an expert, just learning like you probably are if you're interested in
helping with Kelm, so don't worry about barrier of entry. If you'd like to help
by contributing an implementation yourself or fixing up mine, submit a pull
request on github, but file an issue first so I know you're working on that.