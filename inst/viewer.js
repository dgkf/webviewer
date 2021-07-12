'use strict';

const e = React.createElement;

class Viewer extends React.Component {
  constructor(props) {
    super(props);
    this.handleResize = this.handleResize.bind(this);
    this.state = { 
      content: false 
    };
  }

  render() {
    if (this.state.content) {
      return e(
        'div',
        { 
          className: 'viewer-content', 
          dangerouslySetInnerHTML: { __html: this.state.content } 
        }
      );
    }

    return e(
      'div',
      { className: 'viewer-content' },
      'Awaiting Connection...',
    );
  }

  componentDidMount() {
    window.addEventListener("resize", this.handleResize);

    // create a websocket 
    var prot = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    var path = window.location.pathname
    var path = path.endsWith('/') ? path : path + '/'

    this.ws_url = prot + '//' + window.location.host + path + 'ws';
    this.ws = new WebSocket(this.ws_url);

    this.ws.onopen = () => {
      console.log('websocket connected at ' + this.ws_url);
    }

    this.ws.onmessage = evt => {
      console.log('websocket message recieved');
      this.setState({ content: evt.data });
    }

    this.ws.onclose = () => {
      console.log('websocket closed');
    }
  }

  componentWillUnmount() {
    window.addEventListener("resize", null);
    this.ws.close();
  }

  handleResize = () => {
    console.log("sending updated dimensions")
    this.ws.send(JSON.stringify({ 
      width: window.innerWidth, 
      height: window.innerHeight
    }));
  };
}

var viewer = e(Viewer)

const domContainer = document.querySelector('#viewer-container');
ReactDOM.render(viewer, domContainer);

