#let xor(a, b, bits: 32) = {
    import calc: *
    let x = 0
    for k in range(bits) {
        x += int(odd(a) != odd(b)) * pow(2, k)
        a = quo(a, 2)
        b = quo(b, 2)
    }
    x
}

#let slice(x, bits: 32) = calc.rem(x, calc.pow(2, bits))

#let le32(n) = {
    assert(n >= 0 and n < calc.pow(2, 32))
    for _ in range(4) {
        (calc.rem(n, 256),)
        n = calc.quo(n, 256)
    }
}

#let be32(n) = le32(n).rev()

#let crc32-table = for n in range(256) {
    let c = n
    for k in range(8) {
        if calc.odd(c) {
            c = xor(0xEDB88320, calc.quo(c, 2))
        } else {
            c = calc.quo(c, 2)
        }
    }
    (c,)
}

#let crc32(bytes) = {
    let crc = 0xFFFFFFFF
    for n in bytes {
        let x = crc32-table.at(xor(crc, n, bits: 8))
        crc = xor(x, calc.quo(crc, 256))
    }
    xor(crc, 0xFFFFFFFF)
}

#let adler32(bytes) = {
    let (a, b) = (1, 0)
    for n in bytes {
      a = calc.rem(a + n, 65521)
      b = calc.rem(a + b, 65521)
    }
    b * calc.pow(2, 16) + a
}

#let chunk(type, data) = {
    let type = array(bytes(type))
    be32(data.len())
    type
    data
    be32(crc32(type + data))
}
