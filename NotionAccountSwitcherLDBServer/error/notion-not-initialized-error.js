"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const routing_controllers_1 = require("routing-controllers");
class NotionNotInitializedError extends routing_controllers_1.HttpError {
    constructor() {
        super(403, 'Notion data not found. Please login first from notion app.');
    }
}
exports.default = NotionNotInitializedError;
