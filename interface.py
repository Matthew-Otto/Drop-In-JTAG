from telnetlib import Telnet

# OpenOCD supports tcl, but I'd rather use python over telnet \//


def main():
    global tn
    with Telnet("10.55.0.1", 4444) as tn:
        a = read()
        print(a)

        a = execute("scan_chain")
        print(a)

        a = state("halt")
        print(a)


def state(state):
    """Puts the TAP controller in the specified state"""
    code = ir_codes[state.upper()]
    if not code:
        print("AAA")

    return execute(f"irscan core.tap {code}")


ir_codes = {
    "BYPASS"         : "0xf",
    "IDCODE"         : "0x1",
    "SAMPLE_PRELOAD" : "0x2",
    "EXTEST"         : "0x3",
    "INTEST"         : "0x4",
    "CLAMP"          : "0x5",
    "HALT"           : "0x6",
    "STEP"           : "0x7",
    "RESUME"         : "0x8",
    "RESET"          : "0x9",
}


def execute(cmd):
    write(cmd)
    return read()

def write(cmd):
    tn.write(cmd.encode('ascii') + b"\n")

def read():
    data = b""
    while True:
        rd = tn.read_until(b"\n", timeout=0.1)
        if not rd:
            break
        else:
            data += rd

    return data.decode('ascii')


if __name__ == "__main__":
    main()