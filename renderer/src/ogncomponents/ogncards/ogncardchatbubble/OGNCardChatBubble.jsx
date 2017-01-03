/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/

import React from 'react';
import { inject, observer } from 'mobx-react';
import './OGNCardChatBubble.css';

class OGNCardChatBubble extends React.Component {

	static propTypes = {
		item: React.PropTypes.object.isRequired
	};

	render() {

		var item = this.props.item;
		let text = item["urn:consumer:message:text"];
		let senderid = item["urn:consumer:id"];

		if (senderid !== "ai:offgrid") {
			return (
				<div className="my-chat-bubble">{text}</div>
			)
		} else {
			return (
				<div className="receiver-chat-bubble">{text}</div>
			)
		}
	}
}

export default inject('store')(observer(OGNCardChatBubble))
