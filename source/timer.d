/**
* Timer utility class 
*/

import derelict.sdl2.sdl;

class Timer {

    private int mStartTicks;
    private int mPausedTicks;
    private bool mStarted;
    private bool mPaused;

    /**
     * Timer constructor.  Since int defaults to 0 and bool to false, we don't
     * need to do anything.
     */
    this() {}

    /**
     * Start the timer.
     */
    void start() {
        mStarted = true;
        mPaused = false;
        mStartTicks = SDL_GetTicks();
    }

    /**
     * Stops the timer.
     */
    void stop() {
        mStarted = false;
        mPaused = false;
    }

    /**
     * Pause the timer.
     */
    void pause() {
        mPaused = true;
        mPausedTicks = SDL_GetTicks() - mStartTicks;
    }

    /**
     * Unpause the timer.
     */
    void unpause() {
        if (mPaused) {
            mPaused = false;
            mStartTicks = SDL_GetTicks() - mPausedTicks;
            mPausedTicks = 0;
        }
    }

    /**
     * Restart the timer and get the elapsed number of ticks since it ran.
     * @return The number of ticks elapsed.
     */
    int restart() {
        int elapsedTicks = ticks();
        start();
        return elapsedTicks;
    }

    /**
     * Returns the amount of ticks.
     * @return The number of ticks elapsed since the timer started, the number
     * of ticks of the paused timer, or 0 if the timer hasn't started.
     */
    int ticks() {
        if (mStarted) {
            if (mPaused) {
                return mPausedTicks;
            } else {
                return SDL_GetTicks() - mStartTicks;
            }
        }
        return 0;
    }

    /**
     * Returns whether the timer is started.
     * @param Is the timer started?
     */
    bool started() {
        return mStarted;
    }

    /**
     * Returns whether the timer is paused.
     * @param Is the timer paused?
     */
    bool paused() {
        return mPaused;
    }
}
