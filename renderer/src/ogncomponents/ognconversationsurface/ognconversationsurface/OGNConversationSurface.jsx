/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/

import React from 'react';
import { OGNConversationScroller, OGNConversationSendBox } from './../../OGNComponents';
import { inject, observer } from 'mobx-react';
import './OGNConversationSurface.css';

class OGNConversationSurface extends React.Component {
  render() {
    return (
      <div>
        <div className="ogn-conversation-surface-background" />
        <OGNConversationScroller />
        <OGNConversationSendBox />
      </div>
    )
  }
}

export default inject('store')(observer(OGNConversationSurface))