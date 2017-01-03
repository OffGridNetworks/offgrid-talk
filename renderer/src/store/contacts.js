/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/

import { extendObservable, observable, computed } from "mobx"
import { toJS } from 'mobx';
const DEFAULT = { "urn:consumer:id": "me" }

class ContactsStore {

  constructor() {
       try {
           this.mru = JSON.parse(sessionStorage.getItem("contacts/mru"));
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
    sessionStorage.setItem("contacts/mru", blob);

    return Promise.resolve(true);
   };

   clear = () => {
    this.items.splice(0);
    this.mru.push(0);
    this.push(DEFAULT);
    sessionStorage.setItem("contacts/mru", []);
    return Promise.resolve(true);
   };

}

const contacts = new ContactsStore();
export default contacts;
