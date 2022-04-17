// MIT License
// Copyright (c) 2022 Yuta Saito
// https://github.com/kateinoigakukun/irb.wasm

import * as Comlink from "comlink"
import { StdinProducer } from "./sync-stdin";
import jQuery from "jquery"
// @ts-ignore
import initTerminalPlugin from "jquery.terminal";
import initUnixFormatting from "jquery.terminal/js/unix_formatting"
import "jquery.terminal/css/jquery.terminal.css"

initTerminalPlugin(jQuery)
initUnixFormatting(window, jQuery)

function checkAvailability() {
    if (typeof SharedArrayBuffer == "undefined") {
        alert("Your browser doesn't support SharedArrayBuffer now. Please use the latest Chrome.")
        throw new Error("no SharedArrayBuffer");
    }
}

interface IrbWorker {
    init(
        termWriter: (_: string) => void,
        requestStdinByte: () => void,
        stdinBuffer: SharedArrayBuffer
    ): void;
}

async function init() {
    navigator.serviceWorker.register(
        new URL('service-worker.ts', import.meta.url),
        {type: 'module'}
    );

    checkAvailability()
    const irbWorker: Comlink.Remote<IrbWorker> = Comlink.wrap(
        // @ts-ignore
        new Worker(new URL("repl-worker.ts", import.meta.url), {
            type: "module"
        })
    );

    const stdinConnection = new SharedArrayBuffer(16);
    const stdinProducer = new StdinProducer(new Int32Array(stdinConnection));

    const term = jQuery("#terminal").terminal((line) => {
        stdinProducer.writeLine(Array.from(line + "\n"))
    }, {
        greetings: null,
        prompt: "",
    });

    irbWorker.init(
        /* termWriter: */ Comlink.proxy((text) => {
        term.echo(text, { newline: false })
    }),
        /* requestStdinByte: */ Comlink.proxy(() => {
        stdinProducer.onNewRequest();
    }),
        stdinConnection
    )

    // @ts-ignore
    window.term = term;
}

init()
