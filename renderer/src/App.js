/*
* OffGrid Talkie
*
* Copyright (c) 2017 OffGrid Networks. All Rights Reserved.
* SEE LICENSE
*/

import React, { Component } from 'react';
import logo from './../public/imgs/app/ogn_logo.svg';
import './App.css';
import { OGNSideBar, OGNConversationSurface } from './ogncomponents/OGNComponents.jsx'

class App extends Component {
  render() {
    return (
      <div className="App">
        <div className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
        </div>
        <OGNSideBar >
          <ul>
            <li className="ogn-sidebar-item App-sidebar-heading">Connected</li>
            <li className="ogn-sidebar-item App-sidebar-item"><a href="#">Shout</a></li>
            </ul>
        </OGNSideBar>
        <OGNConversationSurface id="chat" />
      </div>
    );
  }
}

export default App;
