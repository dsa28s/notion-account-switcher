import 'reflect-metadata';

import { createExpressServer } from 'routing-controllers';
import {SERVER_PORT} from './constant';
import Log from './utils/log';
import CheckController from './controller/check-controller';

const app = createExpressServer({
  controllers: [CheckController],
  defaults: {
    nullResultCode: 404,
  }
});

Log.shared.info(`Notion Account Switcher server started. (port: ${SERVER_PORT})`);
app.listen(SERVER_PORT);
