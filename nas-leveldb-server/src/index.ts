import 'reflect-metadata';

import { createExpressServer } from 'routing-controllers';
import {SERVER_PORT} from './constant';
import Log from './utils/log';
import CheckController from './controller/check-controller';
import DataController from './controller/data-controller';

const app = createExpressServer({
  controllers: [CheckController, DataController],
  defaults: {
    nullResultCode: 404,
  }
});

Log.shared.info(`Notion Account Switcher server started. (port: ${SERVER_PORT})`);
app.listen(SERVER_PORT);
