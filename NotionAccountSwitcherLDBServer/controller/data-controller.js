"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const routing_controllers_1 = require("routing-controllers");
const fs = require("fs");
const repository_1 = require("../repository");
const notion_not_initialized_error_1 = require("../error/notion-not-initialized-error");
let DataController = class DataController {
    getCurrentLoginEmail() {
        return __awaiter(this, void 0, void 0, function* () {
            const lockFilePath = `${repository_1.default.getNotionDataPath()}/LOCK`;
            if (fs.existsSync(lockFilePath)) {
                fs.unlinkSync(lockFilePath);
            }
            if (!fs.existsSync(repository_1.default.getNotionDataPath())) {
                throw new notion_not_initialized_error_1.default();
            }
            return repository_1.default.getLoggedInUser();
        });
    }
};
__decorate([
    routing_controllers_1.Get('/email'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], DataController.prototype, "getCurrentLoginEmail", null);
DataController = __decorate([
    routing_controllers_1.JsonController('/data')
], DataController);
exports.default = DataController;
