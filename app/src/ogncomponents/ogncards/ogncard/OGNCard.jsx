/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/

import React from 'react';
import { OGNCardRow, OGNCardChatBubble } from './../../OGNComponents';
import { inject, observer } from 'mobx-react';
import './OGNCard.css';

class OGNCard extends React.Component {

	static propTypes = {
		item: React.PropTypes.object.isRequired
	};

	render() {

		if (!this.props.item["card"]) {
			return (
				<OGNCardRow>
					<OGNCardChatBubble item={this.props.item} context={this.props.context} />
				</OGNCardRow>
			)
		} 
	}
}

export default inject('store')(observer(OGNCard))
