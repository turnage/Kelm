package body kelm.md5 is

    -- Primitive functions special for md5
    -- -- called: during round functions
    -- -- x: eye of newt
    -- -- y: tale of lizard
    -- -- z: juice of kraken
    -- -- returns: result of ancient witchcraft
    function f (x, y, z : u32) return u32 is
    begin
        return ((x and y) or ((not x) and z));
    end f;

    function g (x, y, z : u32) return u32 is
    begin
        return ((x and z) or (y and (not z)));
    end g;

    function h (x, y, z : u32) return u32 is
    begin
        return (x xor y xor z);
    end h;

    function i (x, y, z : u32) return u32 is
    begin
        return (y xor (x or (not z)));
    end i;
    -- End primitive functions special to md5

    -- Round operations special for md5
    -- -- called: from algorithm hub
    -- -- a, b, c, d: hash intermediate values
    -- -- k: element from message block
    -- -- s: amount to circularly shift
    -- -- i: constant from the sine table
    function round_one (a, b, c, d, k, s, co: u32) return u32 is
    begin
        return rotate_left(a + f(b, c, d) + k + co, integer(s)) + b;
    end round_one;

    function round_two (a, b, c, d, k, s, co: u32) return u32 is
    begin
        return rotate_left(a + g(b, c, d) + k + co, integer(s)) + b;
    end round_two;

    function round_three (a, b, c, d, k, s, co: u32) return u32 is
    begin
        return rotate_left(a + h(b, c, d) + k + co, integer(s)) + b;
    end round_three;

    function round_four (a, b, c, d, k, s, co: u32) return u32 is
    begin
        return rotate_left(a + i(b, c, d) + k + co, integer(s)) + b;
    end round_four;
    -- End round operations special for md5

end kelm.md5;