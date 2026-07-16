package main

import "core:flags"
import "core:fmt"
import "core:log"
import "core:os"
import "core:path/filepath"

Options :: struct {
	enable_log_to_file:       string `args:"name=log-file" usage:"Path to save logs"`,
	enable_log_for_allocator: bool `args:"name=log-alloc" usage:"Enable log for allocations"`,
}

main :: proc() {
	opt: Options
	flags.parse_or_exit(&opt, os.args)

	console_logger := log.create_console_logger()
	defer log.destroy_console_logger(console_logger)

	logger := console_logger
	file_logger: log.Logger
	multi_logger: log.Logger
	using_file := false

	if (opt.enable_log_to_file != "") {

		log_file := fmt.tprint("logs/", opt.enable_log_to_file, sep = "")
		dir_path := filepath.dir(log_file)

		if !os.is_dir(dir_path) {
			dir_err := os.mkdir_all(dir_path)
			if dir_err != os.ERROR_NONE {
				fmt.eprintfln("Failed to create folder path:", dir_err)
				return
			}
		}

		handle, err := os.open(log_file, os.O_RDWR | os.O_APPEND | os.O_CREATE)
		assert(err == nil, "Cannot open log file")

		file_logger = log.create_file_logger(handle)
		multi_logger = log.create_multi_logger(console_logger, file_logger)
		logger = multi_logger
		using_file = true
	}

	defer if using_file {
		log.destroy_file_logger(file_logger)
		log.destroy_multi_logger(multi_logger)
	}
	context.logger = logger

	alloc: log.Log_Allocator
	allocator := context.allocator
	if opt.enable_log_for_allocator {
		fmt.println("Allocation logging enabled")
		log.log_allocator_init(&alloc, .Debug)
		allocator = log.log_allocator(&alloc)
	}
	context.allocator = allocator

	a := new(i32)
	defer free(a)

	log.info("hello world")
	log.error("hello world")
	log.debug("hello world")
	log.warn("hello world")

	fmt.println("Hellope, Odin!")

	a^ = 42

	fmt.println(a^)
	fmt.println("All args", os.args, opt)
}
