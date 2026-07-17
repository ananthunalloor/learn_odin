package main

import "core:flags"
import "core:fmt"
import "core:log"
import "core:os"

Options :: struct {
	log_file_path: string `args:"name=log-path" usage:"Path to save logs"`,
	log_allocator: bool `args:"name=log-alloc" usage:"Enable log for allocations"`,
}

main :: proc() {
	opt: Options
	flags.parse_or_exit(&opt, os.args)

	logger_ctx, ok := setup_logger(opt.log_file_path)
	if !ok {return}
	defer destroy_logger(logger_ctx)

	context.logger = logger_ctx.logger
	context.allocator = setup_allocator_logger(&logger_ctx, opt.log_allocator)


	test :: proc() {
		log.error("what is this called")
	}

	test2 :: proc(fn: proc()) {
		fn()
		log.error("what is this")
	}

	test2(test)


	a := new(i32); defer free(a)

	log.info("hello world")
	log.error("hello world")
	log.debug("hello world")
	log.warn("hello world")

	fmt.println("Hellope, Odin!")

	a^ = 42

	fmt.println(a^)
	fmt.println("All args", os.args, opt)
}
