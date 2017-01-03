/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/

import MessagesStore from './messages';

const store = {
  messages: MessagesStore
};

global.com = global.com || {};
global.com.offgridn = global.com.offgridn || {};
global.com.offgridn.store = store;

export default store;