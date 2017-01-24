/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/

import React from 'react';
import { inject, observer } from 'mobx-react';
import './OGNSideBar.css';

class OGSideBar extends React.Component {
    constructor() {
        super();
        this.state = {
            sidebaropen: false,
        };
    }

    handleClose() {
        this.setState({ sidebaropen: !this.state.sidebaropen });
    }

    render() {
        return (
            <div id={'hamburger' + this.props.store.uistate.screenSize.width}>
                <input type="checkbox" id="ogn-sidebar-hamburger" className="ogn-sidebar-hamburger" onChange={this.handleClose.bind(this)} checked={this.state.sidebaropen} />
                <label htmlFor="ogn-sidebar-hamburger"></label>
                <div className="ogn-sidebar">
                    <a href="#" className="ogn-sidebar-close" onClick={this.handleClose.bind(this)}></a>
                    <div className="ogn-sidebar-content">
                    {this.props.children}       
                    </div>
                </div>
            </div>
        )
    }
}

export default inject('store')(observer(OGSideBar))