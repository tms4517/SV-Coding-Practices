#!/usr/bin/env python3

from math import *
import numpy as np
from numpy.fft import fft, fftshift
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

figsize = (16, 10)

def clog2(x):
    return int(ceil(log(x, 2)))

def flog2(x):
    if 0 == x:
        return -1.0
    else:
        return floor(log(x, 2))

def fractionFmt(x, pos):
    assert isinstance(x, (int, float)), type(x)
    if np.isclose(np.rint(x), x):
        ret = r"$%d$" % int(x)
    else:
        ret = r"$\frac{%d}{%d}$" % x.as_integer_ratio()
    return ret

def plotLogdropWindow(ts, ys, eqn, nm):
    plt.figure(figsize=figsize)
    plt.rc("text", usetex=True)
    plt.rc("font", family="serif", size=12)
    _, ax = plt.subplots()
    ax.yaxis.set_major_formatter(ticker.FuncFormatter(fractionFmt))

    #plt.title(eqn)
    plt.xlabel("$n$")
    plt.ylabel("$w[n]$", y=0.7, rotation="vertical")

    plt.xticks((ts[0], ts[-1]))
    plt.yticks(list(set(y for y in ys if y > 0.05)))
    plt.ylim(0, 1.05)

    if len(ts) < 2**8:
        plt.bar(ts, ys, color="C0")
    else:
        plt.plot(ts, ys, color="C0")

    plt.savefig("logdropWindow_%s.pdf" % nm, bbox_inches='tight')
    plt.close()

def radiansFmt(x, pos):
    assert isinstance(x, (int, float)), type(x)
    xx = x / np.pi
    if np.isclose(np.rint(xx), xx):
        coeff = int(xx)
        if 1 == abs(coeff):
            ret = r"$\pi$" if coeff > 0 else r"$-\pi$"
        elif 0 == coeff:
            ret = r"$0$"
        else:
            ret = r"$%d\pi$" % int(xx)
    else:
        ret = r"$\frac{%d\pi}{%d}$" % xx.as_integer_ratio()
    return ret

def plotFreqResponse(window):
    A = fft(window, 2048) / 25.5
    mag = np.abs(fftshift(A))
    freq = np.linspace(-np.pi, np.pi, len(A))
    response = np.clip(20 * np.log10(mag), -80, 0)

    plt.figure(figsize=figsize)
    plt.rc("text", usetex=True)
    plt.rc("font", family="serif", size=12)
    _, ax = plt.subplots()
    ax.xaxis.set_major_formatter(ticker.FuncFormatter(radiansFmt))

    plt.xlabel("Normalized Frequency (radians/sample)")
    plt.ylabel("Magnitude (dB)", rotation="vertical")
    plt.xticks((freq[0], 0, freq[-1]))

    #plt.plot(response[1:], freq[1:])
    ax.fill_between(freq, -80, response, color="C1")
    plt.ylim(-80, 0)

    plt.savefig("logdropWindow_freq.pdf", bbox_inches='tight')
    plt.close()


n = 2**5 # Larger looks better until ylabels overlap.


# NOTE: This may be the way hardware functions but without using non-standard
# definition of log(0)=0 the maths doesn't make sense.
def w_0idx(t, n):
    assert 0 <= t < n, (t, n)
    #print("t=", t, end=' ')

    # n must be a power of 2 so only a single bit set.
    # The power is the index of the set bit.
    onehotIdxN = int(log2(n/4))
    #print("onehotIdxN=", onehotIdxN)

    # min(t, n-t-1) increments then decrements with t.
    # Use a bi-directional counter, or opposing up/down counters.
    if t < n / 2:
        a = t
    else:
        a = n - t - 1
    #print("a=", a, end=' ')

    # flog2(a) can be found with onehotIdx(find-last-set).
    shft = onehotIdxN - flog2(a)
    #print("shft=", shft, end=' ')

    #print()
    return 1/2**shft


def w_1idx(t, n):
    assert 0 < t <= n, (t, n)
    #print("t=", t, end=' ')

    # n must be a power of 2 so only a single bit set.
    # The power is the index of the set bit.
    onehotIdxN = int(log2(n/2))
    #print("onehotIdxN=", onehotIdxN)

    # min(t, n-t-1) increments then decrements with t.
    # Use a bi-directional counter, or opposing up/down counters.
    if t <= n / 2:
        a = t
    else:
        a = n - t + 1
    #print("a=", a, end=' ')

    shft = onehotIdxN - ceil(log(a, 2))
    #print("shft=", shft, end=' ')

    #print()
    return 1/2**shft

eqn_0idx = r"$t \in [0, n);\ w(t) = 2^{\lceil\log_2\min(t+1, n-t)\rceil - \log_2\frac{n}{2}}$"
def canonical_0idx(t, n):
    return 2**( ceil(log(min(t+1, n-t), 2)) - log(n/2, 2) )


# NOTE: eqn_0idx_altA is dodgy with log(0)!
eqn_0idx_altA = r"$t \in [0, n);\ w(t) = 2^{-( \log_2\frac{n}{4} - \lfloor\log_2\min(t, n-t-1)\rfloor )}$"
ts_0idx = np.arange(0, n, 1)
ys_0idx = [canonical_0idx(t, n) for t in ts_0idx]
ys_0idx_altA = [2**-( log(n/4, 2) - flog2(min(t, n-t-1)) ) for t in ts_0idx]
ys_0idx_altB = [w_0idx(t, n) for t in ts_0idx]
assert all(y == yAlt for y,yAlt in zip(ys_0idx, ys_0idx_altA))
assert all(y == yAlt for y,yAlt in zip(ys_0idx, ys_0idx_altB))
#print("0idx")
#print("ts=", ts_0idx)
#print("ys=", ys_0idx)
plotLogdropWindow(ts_0idx, ys_0idx, eqn_0idx, "0idx")

eqn_1idx = r"$t \in [1, n];\ w(t) = 2^{\lceil\log_2\min(t, n-t+1)\rceil - \log_2\frac{n}{2}}$"
ts_1idx = np.arange(1, n+1, 1)
ys_1idx = [2**( ceil(log(min(t, n-t+1), 2)) - log(n/2, 2) ) for t in ts_1idx]
ys_1idx_alt = [w_1idx(t, n) for t in ts_1idx]
assert all(y == yAlt for y,yAlt in zip(ys_1idx, ys_1idx_alt))
#print("1idx")
#print("ts=", ts_1idx)
#print("ys=", ys_1idx)
plotLogdropWindow(ts_1idx, ys_1idx, eqn_1idx, "1idx")

assert all(y0 == y1 for y0,y1 in zip(ys_0idx, ys_1idx))

plotFreqResponse(ys_0idx)

