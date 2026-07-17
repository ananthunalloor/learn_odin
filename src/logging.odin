package main

import "base:runtime"
import "core:fmt"
import "core:log"
import "core:os"
import "core:path/filepath"

Logger_Context :: struct {
	logger:         log.Logger,
	console_logger: log.Logger,
	file_logger:    log.Logger,
	multi_logger:   log.Logger,
	log_to_file:    bool,
	alloc:          log.Log_Allocator,
}

setup_logger :: proc(log_file_path: string) -> (ctx: Logger_Context, ok: bool) {
	ctx.console_logger = log.create_console_logger()
	ctx.logger = ctx.console_logger

	if (log_file_path != "") {
		log_file := fmt.tprint("logs/", log_file_path, sep = "")
		dir_path := filepath.dir(log_file)

		if !os.is_dir(dir_path) {
			dir_err := os.mkdir_all(dir_path)
			if dir_err != os.ERROR_NONE {
				fmt.eprintfln("Failed to create folder path:", dir_err)
				log.destroy_console_logger(ctx.console_logger)
				return ctx, false
			}
		}

		handle, err := os.open(log_file, os.O_RDWR | os.O_APPEND | os.O_CREATE)
		assert(err == nil, "Cannot open log file")

		ctx.file_logger = log.create_file_logger(handle)
		ctx.multi_logger = log.create_multi_logger(ctx.console_logger, ctx.file_logger)
		ctx.logger = ctx.multi_logger
		ctx.log_to_file = true
	}

	return ctx, true
}

setup_allocator_logger :: proc(ctx: ^Logger_Context, enable: bool) -> runtime.Allocator {
	allocator := context.allocator
	if enable {
		fmt.println("Allocation logging enabled")
		log.log_allocator_init(&ctx.alloc, .Debug)
		allocator = log.log_allocator(&ctx.alloc)
	}
	return allocator
}

destroy_logger :: proc(ctx: Logger_Context) {
	log.destroy_console_logger(ctx.console_logger)
	if ctx.log_to_file {
		log.destroy_file_logger(ctx.file_logger)
		log.destroy_multi_logger(ctx.multi_logger)
	}
}
