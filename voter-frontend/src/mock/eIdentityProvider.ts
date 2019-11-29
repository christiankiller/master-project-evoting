import {mock, axios} from './axiosMock';

// Mock any GET request
// arguments for reply are (status, data, headers)
mock.onGet('/getToken').reply(200, {
  token: '123456789',
});

export const getToken = async (username: string, password: string) => {
  return new Promise(resolve =>
    axios.get('/getToken', {params: {username: 'asd', password: 'asdsad'}}).then((res: any) => {
      return resolve(res.data.token);
    }),
  );
};
