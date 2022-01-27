; vsync interrupt routine

system_vsync_handler:
    call mouse_update
    reti
