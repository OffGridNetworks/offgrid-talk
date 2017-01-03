/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/

import React from 'react';
import { OGNCard, OGNConversationRowHeader } from './../../OGNComponents';
import { inject, observer } from 'mobx-react';
import './OGNConversationScroller.css';

class OGNConversationScroller extends React.Component {

  scrollWindow() {
    window.scrollTo(0, document.body.scrollHeight);
  }

  componentWillMount() {
    this.scrollWindow();
  }

  componentDidMount() {
    window.addEventListener("resize", this.scrollWindow);
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.scrollWindow);
  }

  componentDidUpdate() {
    this.scrollWindow();
  }

  render() {
    let lastDate = new Date(0)
    const listItems = this.props.store.messages.items.map((item, index) => {
      const itemDate = new Date(item["urn:consumer:timestamp"] || null)
      const sender = item["urn:consumer:id"]
      const prevDate = lastDate
      lastDate = itemDate
      return (
        <div key={index} >
          <OGNConversationRowHeader sender={sender} date={itemDate} prevDate={prevDate} />
          <OGNCard item={item} />
        </div>
      )
    })
    return (
      <div className='ogn-conversation-scroller' ref="scrollView" >
        {listItems}
      </div>
    )
  }
}

export default inject('store')(observer(OGNConversationScroller))