"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("reflect-metadata");
const routing_controllers_1 = require("routing-controllers");
const constant_1 = require("./constant");
const log_1 = require("./utils/log");
const check_controller_1 = require("./controller/check-controller");
const data_controller_1 = require("./controller/data-controller");
const app = routing_controllers_1.createExpressServer({
    controllers: [check_controller_1.default, data_controller_1.default],
    defaults: {
        nullResultCode: 404,
    }
});
log_1.default.shared.info(`Notion Account Switcher server started. (port: ${constant_1.SERVER_PORT})`);
app.listen(constant_1.SERVER_PORT);
