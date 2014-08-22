/**
 * sprite-blitting
 *
 * A sample app to explore how to leverage SDL2's functions to perform
 * sprite bltting from a spritesheet to a window, as well as performing
 * color transformations on it.
 *
 * Author: Jan (ysgard) Van Uytven, ysgard@gmail.com
 * @2014
 */

import std.stdio;
import std.string;
import std.random;

// Derelict2
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import util;
import window;
import timer;

immutable WINDOW_WIDTH = 1200;
immutable WINDOW_HEIGHT = 800;


int main()
{
	// Load the SDL2 Libraries
	DerelictSDL2.load();
	DerelictSDL2Image.load();
	DerelictSDL2ttf.load();

	// Initialize
	if (SDL_Init(SDL_INIT_EVERYTHING == -1)) {
		writefln(SDLErrorStr("Could not initialize SDL!"));
	}
	if (TTF_Init() == -1) {
		writefln(SDLErrorStr("Could not initialize TTF_SDL!"));
	}
	scope(exit) {
		SDL_Quit();
		TTF_Quit();
	}

	// Create a window
	auto main_window = new Window("Sprite Blitting", WINDOW_WIDTH, WINDOW_HEIGHT);

	// Create a debugging window to catch log messages
	//auto debug_window = new Window("Debug Window", 800, 300);

	// Load the spritesheet image
	auto sprite_surface = loadImage("data/BrogueFont5.png");
	
	// Convert the black pixels into transparent pixels
	if (!SDL_SetColorKey(sprite_surface, true, 0x00000000)) {
		writefln(SDLErrorStr("Cannot set color key on spritesheet!"));
	}

	// Convert the resulting surface to a texture
	auto sprite_sheet = SDL_CreateTextureFromSurface(main_window.renderer(), sprite_surface);

	// Create a 'punch' for getting the sprites out of the spritesheet.
	SDL_Rect sprite_clip = { 0, 0, 18, 28 };


	// Get information about the spritesheet and the window
	SDL_Rect window_size = { 0, 0, 0, 0 };
	SDL_Rect sheet_size = { 0, 0, 0, 0 };
	if (SDL_QueryTexture(sprite_sheet, null, null, &sheet_size.w, &sheet_size.h)) {
		writefln(SDLErrorStr("Error getting the size of the spritesheet texture"));
	}
	SDL_GetWindowSize(main_window.window(), &window_size.w, &window_size.h);

	// Create the clip rectangle we want to blit the spritesheet into
	SDL_Rect clip_rect = { (window_size.w - sheet_size.w) / 2,
												 (window_size.h - sheet_size.h) / 2,
												 sheet_size.w, sheet_size.h };

	// Create a texture to store our changes so we can control when we blit to the screen
	auto buffer_tex = SDL_CreateTexture(main_window.renderer(),
																			SDL_PIXELFORMAT_RGBA8888,
																			SDL_TEXTUREACCESS_TARGET,
																			window_size.w, window_size.h);
	
	// Get a timer and start it
	Timer t = new Timer;
	scope(exit) { t.stop(); }
	t.start();
	int old_seconds = -1;
	int seconds = 0; // To force an immediate draw

	
	// Main event loop
	bool quit = false;
	while (!quit) {

		SDL_Event e;
		while (SDL_PollEvent(&e)) {
			// If the user closes the window, break and exit
			switch (e.type) {
			case SDL_QUIT:
				quit = true;
				break;
			case SDL_MOUSEBUTTONDOWN:
				quit = true;
				break;
			default:
				break;
			}
		}

		
		//debug_window.clear();

		// Blit the spritesheet texture into the window at the coords of the clip rectangle
		// if(SDL_RenderCopy(main_window.renderer(), sprite_sheet, null, &clip_rect)) {
		// 	writefln(SDLErrorStr("Could not blit spritesheet to window!"));
		// }

		// Fill the entire screen with random sprites with random colors!
		// We only do this every 1000 ticks.
		seconds = t.ticks() / 1000 ;
		if (seconds > old_seconds) {
			SDL_SetRenderTarget(main_window.renderer(), buffer_tex);
			SDL_RenderClear(main_window.renderer());
			foreach (int i; 0 .. window_size.w / sprite_clip.w) {
				foreach (int j; 0 .. window_size.h / sprite_clip.h) {
					// Random letter
					int glyph_x = uniform(0, 16);
					int glyph_y = uniform(3, 16);
					// random color
					SDL_Color r_color = { cast(ubyte)uniform(0, 256),
																cast(ubyte)uniform(0, 256),
																cast(ubyte)uniform(0, 256),
																0 };
					// Now blit the random glyph from the spritesheet to the screen
					// using the random color
					SDL_Rect dest_rect = { i * 18, j * 28, 18, 28 };
					SDL_Rect src_rect = {  glyph_x * 18, glyph_y * 28, 18, 28 };
					SDL_SetTextureColorMod(sprite_sheet, r_color.r, r_color.g, r_color.b);
					SDL_RenderCopy(main_window.renderer(), sprite_sheet, &src_rect, &dest_rect);
				}
			}
			old_seconds = seconds;
			// Reset render target back to main window
			SDL_SetRenderTarget(main_window.renderer(), null);
		}

		SDL_RenderCopy(main_window.renderer(), buffer_tex, null, null);

		main_window.present();
		main_window.clear();
	}
	return 0;
}
