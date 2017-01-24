/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/

import React from 'react';
import { inject, observer } from 'mobx-react';
import './OGNConversationSendBox.css';

class OGNConversationSendBox extends React.Component {

  onSubmit(event) {
    event.preventDefault();

    var messageRecord = {
      "urn:consumer:message:text": this.refs.input.innerText,
      "urn:consumer:id": "guy",
      "urn:consumer:timestamp": new Date().getTime()
    }
    this.props.store.messages.closeLastCard();
    this.props.store.messages.push(messageRecord);

    this.refs.input.innerText = '';
  }

  keyPress(event) {
    if (event.charCode === 13) {
      this.onSubmit(event);
    }

  }

   scrollWindow() {
    window.scrollTo(0, document.body.scrollHeight);
  }

  componentDidUpdate() {
    this.scrollWindow();
  }

  render() {
    return (
      <div className="ogn-conversation-sendbox-holder">
        <div className="ogn-conversation-sendbox"
          placeholder="Type a message..."
          contentEditable
          dangerouslySetInnerHTML={{ __html: this.entry }}
          onKeyPress={this.keyPress.bind(this)}
          ref='input'
          />
      </div>
    )
  }
}

export default inject('store')(observer(OGNConversationSendBox))