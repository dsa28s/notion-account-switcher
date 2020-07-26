import 'reflect-metadata';

import { createExpressServer } from 'routing-controllers';

const app = createExpressServer({
  controllers: []
});

app.listen(7555);
