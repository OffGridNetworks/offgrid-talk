/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/

import { extendObservable, observable, computed } from "mobx"
import { toJS } from 'mobx';
const DEFAULT = { "urn:consumer:conversation": 0, "urn:consumer:ids": ["shout"] }

class ConversationsStore {

  constructor() {
       try {
           this.mru = JSON.parse(sessionStorage.getItem("conversations/mru"));
        } catch ( ex){
            this.mru =  null;
        }

    this.mru = this.mru ||  [ DEFAULT ]

    extendObservable(this, {
      items: this.mru
    });

  }

  json = computed(() => {
    return toJS(this.items);
  });

  push = (item) => {
 
    this.items.push(observable(item));

    this.mru.push(toJS(item));

    if (this.mru.length > 9)  this.mru.splice(0, 1);
    var blob = JSON.stringify(toJS(this.mru));
    sessionStorage.setItem("conversations/mru", blob);

    return Promise.resolve(true);
   };

   clear = () => {
    this.items.splice(0);
    this.mru.push(0);
    this.push(DEFAULT);
    sessionStorage.setItem("conversations/mru", []);
    return Promise.resolve(true);
   };

}

const conversations = new ConversationsStore();
export default conversations;
