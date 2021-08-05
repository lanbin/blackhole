<template>
  <div class="alma-header">
    <div class="container">
      <div class="logo">Alma RedPacket</div>
      <div class="nav">
        <el-button type="primary" size="small" @click="mint">Mint SHIBA</el-button>
      </div>
      <div class="op">
        <connect-wallet-btn></connect-wallet-btn>
      </div>
    </div>
  </div>
</template>

<script>
  import { MintShiba } from 'utils/Provider';
  import ConnectWalletBtn from 'comp/ConnectWalletBtn';
  import { mapActions, mapGetters } from 'vuex';

  export default {
    data() {
      return {};
    },
    components: {
      ConnectWalletBtn,
    },
    watch: {},
    computed: {
      ...mapGetters(['$accountHash']),
    },
    mounted() {
      // 切链刷新页面
      if (window.starcoin) {
        window.starcoin.on('chainChanged', () => window.location.reload());
      }
    },
    methods: {
      mint() {
        MintShiba().then((txn) => {
          this.$addTxn(txn);
          this.$message.success('Minit Request has been submit');
        });
      },
      ...mapActions(['$addTxn']),
    },
  };
</script>

<style lang="less" scoped>
  .alma-header {
    width: 100%;
    // background-color: var(--panelBgColor);
    background-color: #d43535;
    display: flex;
    justify-content: center;
    color: white;

    .container {
      min-height: 56px;
      display: flex;
      align-items: center;

      .logo {
        font-size: 30px;
        font-weight: bolder;
      }

      .nav {
        display: flex;
        margin: 0 2rem;
        font-size: 14px;

        .nav-item {
          margin-right: 1rem;
          cursor: pointer;
          font-weight: 800;

          &:hover,
          &.active {
            color: var(--mainTextHoverColor);
          }
        }
      }

      .op {
        margin-left: auto;
        display: flex;
        justify-content: space-between;
        // width: 220px;

        .sign-up-btn {
          padding: 5px 10px;
        }
      }
    }
  }
</style>
