# Video sync

Generates sync timing pulses and data for a PAL video stream using DMA and Timers.

Seems to work with a very simple stub data routine. Needs a bit more work to
be finished. NOTE this currently uses an external clock, set EXT_CLOCK to 0 to use the internal clock.

There is some documentation in this [blog post](https://www.ibbotson.co.uk/stm8/2021/09/11/stm8l-cheap-video-timing.html).

Timing diagrams
![basic timing](https://svg.wavedrom.com/github/peteri/stm8ldiscovery/main/VideoSync/timer3.json)

![sync timing](https://svg.wavedrom.com/github/peteri/stm8ldiscovery/main/VideoSync/timer1.json)

![vid data](https://svg.wavedrom.com/github/peteri/stm8ldiscovery/main/VideoSync/timer2.json)
