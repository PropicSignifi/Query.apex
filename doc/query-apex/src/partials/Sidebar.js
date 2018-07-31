'use strict';

import {isServerSide} from 'metal';
import Component from 'metal-component';
import Soy from 'metal-soy';
import Toggler from 'metal-toggler';

import templates from './Sidebar.soy.js';

class Sidebar extends Component {
	attached() {
		if (isServerSide()) {
			return;
		}

		this.toggler = new Toggler({
			content: '.sidebar-toggler-content',
			header: '.sidebar-header'
		});
	}

	disposed() {
		const {toggler} = this;

		if (toggler) {
			this.toggler.dispose();
		}
	}
};

Soy.register(Sidebar, templates);

export default Sidebar;
