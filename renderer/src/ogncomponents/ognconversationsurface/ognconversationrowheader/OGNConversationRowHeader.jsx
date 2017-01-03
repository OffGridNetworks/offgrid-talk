/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/
 
import moment from 'moment'
import React from 'react';
import { inject, observer } from 'mobx-react';
import './OGNConversationRowHeader.css';

class OGNConversationRowHeader extends React.Component {
	render() {		
		//this.props.sender
		if ((this.props.date - this.props.prevDate) / (1000 * 60 ) > 10)
		 return (
				<h6 className="ogn-conversation-row-header text-center" >
				{moment(this.props.date).fromNow()} ({this.props.sender})
				</h6>
				)
          else return null;
	}
}

export default inject('store')(observer(OGNConversationRowHeader))