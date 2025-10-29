module.exports.handler = async (event) => {
  console.log('Event: ', event);
  let placeholder = 'HEALTHY';

  //TODO : Update API to pull most recent SILVER Data
  //TODO : Point another lambda to invoke this one to pull data using CRON
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      status: placeholder,
    }),
  }
}