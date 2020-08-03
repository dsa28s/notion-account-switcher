"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const logger_1 = require("@ekino/logger");
class Log {
    constructor() {
        Log.instance = this;
        logger_1.setLevel('debug');
        logger_1.setOutput(logger_1.outputs.pretty);
        this.logger = logger_1.createLogger('nas:leveldb-server');
    }
    static get shared() {
        if (!Log.instance) {
            Log.instance = new Log();
        }
        return this.instance;
    }
    info(message, extra) {
        this.logger.info(message, extra);
    }
    warning(message, extra) {
        this.logger.warn(message, extra);
    }
    error(message, extra) {
        this.logger.error(message, extra);
    }
}
exports.default = Log;
