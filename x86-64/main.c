#include <stdio.h>
#include "allegro5/allegro.h"
#include "julia.h"

#define LENGTH 500

int initialization();

void draw(ALLEGRO_BITMAP* bitmap, float real, float img, float translation, float x, float y);

int main() {

    float real, img;

    printf("At first, please enter real and imaginary part of your complex number\n");
    printf("Some nice examples: -1.125 + 0.25\n-0.123 + 0.745i\n0.355 + 0.355i\n-0.54 + 0.54i\n-0.4 - 0.59i\n-0.10 - 0.65i\n");

    // taking arguments from user
    printf("Enter your real number: ");
    if (!scanf("%f", &real)) {
        printf("Wrong value\n");
        return 1;
    }

    printf("Enter your imaginary number: ");
    if (!scanf("%f", &img)) {
        printf("Wrong value\n");
        return 1;
    }

    // checking allegro initialization
    if(!initialization())
        return 1;

    // display
    ALLEGRO_DISPLAY* display = al_create_display(LENGTH, LENGTH);

    // event queue
    ALLEGRO_EVENT_QUEUE* queue = al_create_event_queue();
    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_mouse_event_source());

    // bitmap
    ALLEGRO_BITMAP* bitmap = al_create_bitmap(LENGTH, LENGTH); // load bmp on screen
    al_set_target_bitmap(al_get_backbuffer(display));

    // data initialization
    float translation = 3.0/LENGTH, x = -1.5, y=-1.5;

    // all the magic happens here
    draw(bitmap, real, img, translation, x, y);

    while (true){
        ALLEGRO_EVENT event;
        al_wait_for_event(queue, &event);

        // closing
        if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE || event.type == ALLEGRO_EVENT_DISPLAY_CLOSE){
            al_destroy_event_queue(queue);
            al_destroy_bitmap(bitmap);
            al_destroy_display(display);
            return 0;
        }

        // zooming - mouse click
        if (event.type == ALLEGRO_EVENT_MOUSE_BUTTON_DOWN){
            x += event.mouse.x * translation;
            y += translation * LENGTH;
            y -= event.mouse.y * translation;

            translation /= 1.5;

            x -= translation * LENGTH / 2;
            y -= translation * LENGTH / 2;

            draw(bitmap, real, img, translation, x, y);
        }

        // zooming to the centre of image - z
        if (event.keyboard.keycode == ALLEGRO_KEY_Z){
            x += (LENGTH/2) * translation;
            y += translation * LENGTH;
            y -= (LENGTH/2) * translation;

            translation /= 1.2;

            x -= translation * LENGTH / 2;
            y -= translation * LENGTH / 2;

            draw(bitmap, real, img, translation, x, y);
        }

        // unzooming - space
        if (event.keyboard.keycode == ALLEGRO_KEY_SPACE){
            x += (LENGTH/2) * translation;
            y += translation * LENGTH;
            y -= (LENGTH/2) * translation;

            translation *= 1.2;

            x -= translation * LENGTH / 2;
            y -= translation * LENGTH / 2;

            draw(bitmap, real, img, translation, x, y);
        }

        // going right - d
        if (event.keyboard.keycode == ALLEGRO_KEY_D){
            x += ((LENGTH/2) + 10) * translation;
            y += translation * LENGTH;
            y -= (LENGTH/2) * translation;

            x -= translation * LENGTH / 2;
            y -= translation * LENGTH / 2;

            draw(bitmap, real, img, translation, x, y);
        }

        // going left - a
        if (event.keyboard.keycode == ALLEGRO_KEY_A){
            x += ((LENGTH/2) - 10) * translation;
            y += translation * LENGTH;
            y -= (LENGTH/2) * translation;

            x -= translation * LENGTH / 2;
            y -= translation * LENGTH / 2;

            draw(bitmap, real, img, translation, x, y);
        }

        // going up - w
        if (event.keyboard.keycode == ALLEGRO_KEY_W){
            x += (LENGTH/2) * translation;
            y += translation * LENGTH;
            y -= ((LENGTH/2) - 10) * translation;

            x -= translation * LENGTH / 2;
            y -= translation * LENGTH / 2;

            draw(bitmap, real, img, translation, x, y);
        }

        // going down - s
        if (event.keyboard.keycode == ALLEGRO_KEY_S){
            x += (LENGTH/2) * translation;
            y += translation * LENGTH;
            y -= ((LENGTH/2) + 10) * translation;

            x -= translation * LENGTH / 2;
            y -= translation * LENGTH / 2;

            draw(bitmap, real, img, translation, x, y);
        }
    }
}

int initialization(){
    if(!al_init()){
        printf("There was an error in allegro initialization");
        return 0;
    }

    if(!al_install_mouse()){
        printf("There was an error in keyboard initialization");
        return 0;
    }

    if(!al_install_keyboard()){
        printf("There was an error in mouse initialization");
        return 0;
    }

    return 1;
}

void draw(ALLEGRO_BITMAP* bitmap, float real, float img, float translation, float x, float y){
    ALLEGRO_LOCKED_REGION *region = al_lock_bitmap(bitmap, ALLEGRO_PIXEL_FORMAT_ANY,ALLEGRO_LOCK_READWRITE);

    unsigned *pixels_array;
    pixels_array = (unsigned*) region->data;
    pixels_array = pixels_array + LENGTH - LENGTH*LENGTH;

    julia(pixels_array, LENGTH, real, img, translation, x, y);

    al_unlock_bitmap(bitmap); //save changes and print on screen
    al_clear_to_color(al_map_rgb(0, 0, 0));
    al_draw_bitmap(bitmap, 0, 0, 0);
    al_flip_display();
}
