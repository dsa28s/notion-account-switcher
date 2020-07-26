import 'reflect-metadata';

import { createExpressServer } from 'routing-controllers';
import {SERVER_PORT} from './constant';
import Log from './utils/log';

const app = createExpressServer({
  controllers: [],
  defaults: {
    nullResultCode: 404,
  }
});

Log.shared.info(`Notion Account Switcher server started. (port: ${SERVER_PORT})`);
app.listen(SERVER_PORT);
