<template>
  <div class="home">
    <div class="container">
      <header>
        <h1>Black Hole</h1>
        <el-button size="mini" type="success" :disabled="!hasAmount" @click="claim">
          Claim {{ rawAmount / $precision }} Quark
        </el-button>
        <connect-wallet-btn class="connect-btn"></connect-wallet-btn>
      </header>

      <div class="invite" v-if="inviteLink">
        <h1>
          Invite Link
          <span
            v-clipboard:copy="inviteLink"
            v-clipboard:success="onCopy"
            v-clipboard:error="onCopyError"
          >
            (click the link)
          </span>
        </h1>
        🎁
        <span
          v-clipboard:copy="inviteLink"
          v-clipboard:success="onCopy"
          v-clipboard:error="onCopyError"
        >
          {{ inviteLink }}
        </span>
      </div>

      <el-card class="burn-card">
        <h2>Burn it!</h2>
        <el-form ref="burn-form" :model="burnData">
          <el-form-item
            label="Token: "
            prop="token_identifier"
            :rules="[
              {
                required: true,
                message: 'Select a token type!',
                trigger: ['change', 'blur'],
              },
            ]"
          >
            <el-select v-model="burnData.token_identifier">
              <el-option
                v-for="(resource, index) in resourcesList"
                :key="index"
                :label="resource.name"
                :value="index"
                value-key="name"
              >
                <span class="token-option">
                  {{ resource.name }}
                  <em>{{ resource.amount }}</em>
                </span>
              </el-option>
            </el-select>
          </el-form-item>
          <el-form-item
            label="Burn Amount: "
            prop="token_amount"
            :rules="[
              {
                required: true,
                type: 'number',
                trigger: ['change', 'blur'],
                validator: (rule, value, callback) => {
                  if (isNaN(value)) {
                    return callback('Please enter a number!');
                  }

                  if (value > currentTokenAmount || value <= 0) {
                    return callback(
                      'Please enter a number less than or equal to the current token amount!',
                    );
                  }
                  return callback();
                },
              },
            ]"
          >
            <p>Max: {{ currentTokenAmount }}</p>
            <el-input v-model.number="burnData.token_amount" :max="currentTokenAmount">
              <template slot="append">{{ currentTokenType }}</template>
            </el-input>
          </el-form-item>
          <el-form-item label="Comments: ">
            <el-input type="textarea" resize="none" rows="5" v-model="burnData.comment"></el-input>
            <p class="hints">Gas Fee: 1 QUARK</p>
          </el-form-item>
          <el-form-item>
            <el-button type="danger" @click="burn">Destory the Token</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script>
  import BigNumber from 'bignumber.js';
  import { GetAmout, ClaimReward, Account_Info, BurnToken } from 'utils/Provider';
  import { withPrecision, withoutPrecision } from 'utils';
  import ConnectWalletBtn from 'comp/ConnectWalletBtn';
  import { mapGetters } from 'vuex';

  export default {
    name: 'Home',
    components: {
      ConnectWalletBtn,
    },
    data() {
      return {
        rawAmount: 0,
        resourcesList: [],
        burnData: {},
      };
    },
    computed: {
      hasAmount() {
        return this.rawAmount > 0;
      },
      currentTokenType() {
        if (
          this.burnData.token_identifier != '' &&
          typeof this.burnData.token_identifier !== 'undefined'
        ) {
          return this.resourcesList[this.burnData.token_identifier].name.toUpperCase();
        }
        return 'STC';
      },
      currentTokenAmount() {
        if (
          this.burnData.token_identifier != '' &&
          typeof this.burnData.token_identifier !== 'undefined'
        ) {
          return this.resourcesList[this.burnData.token_identifier].amount;
        }
        return 0;
      },
      inviteLink() {
        return this.$accountHash
          ? `${window.location.origin}/${
              this.$router.resolve({
                name: 'Home',
                query: { invite_address: this.$accountHash },
              }).href
            }`
          : '';
      },
      ...mapGetters(['$accountHash', '$precision']),
    },
    watch: {
      $accountHash() {
        this.init();
      },
    },
    mounted() {
      this.init();
    },
    methods: {
      init() {
        if (this.$accountHash) {
          this.hasAirDrop();
          this.accountInfo();
        }
      },
      hasAirDrop() {
        GetAmout({
          address: this.$accountHash,
        }).then((res) => {
          this.rawAmount = res;
        });
      },
      accountInfo() {
        Account_Info(this.$accountHash).then((res) => {
          this.resourcesList = res;
        });
      },
      claim() {
        const { invite_address = '0xb987F1aB0D7879b2aB421b98f96eFb44' } = this.$route.query;
        ClaimReward({ invite_address })
          .then((txn) => {
            this.$message.success('Quark Claimed!');
            this.init();
          })
          .catch((err) => {
            console.log(err.body);
          });
      },
      onCopy() {
        this.$notification.success(
          'Invite Link has been copied! Share to your friends to get Quark!',
        );
      },
      onCopyError() {
        this.$notification.error('Failed! Try again!');
      },
      burn() {
        this.$refs['burn-form'].validate((valid) => {
          if (!valid) return;

          BurnToken({
            ...this.burnData,
            token_identifier: this.resourcesList[this.burnData.token_identifier]?.tokenName,
            token_amount: this.burnData.token_amount * this.$precision,
          })
            .then((txn) => {
              console.log(txn);
              this.$message.success('Burned!');
              this.burnData = { token_identifier: '', token_amount: 0, comment: '' };
              this.$refs['burn-form'].resetFields();

              setTimeout(() => {
                this.accountInfo();
              }, 3e3);
            })
            .catch((err) => {
              console.log(err.body);
            });
        });
      },
    },
  };
</script>

<style lang="less" scoped>
  .home {
    width: 100%;
    min-height: 100vh;
    display: flex;
    background-color: #eee;
    justify-content: center;

    .container {
      width: 100%;
      max-width: 1200px;
      margin: 0 20px;
      padding: 20px;
      background-color: #fff;
      box-sizing: border-box;
      position: relative;

      header {
        display: flex;
        align-items: center;
        h1 {
          margin-right: 20px;
        }
        .connect-btn {
          margin-left: auto;
        }
      }
    }
  }

  .burn-card {
    margin: 20px auto 50px;
    width: 600px;

    h2 {
      margin-bottom: 20px;
    }
  }

  .hints {
    font-size: 12px;
    color: #f14646;
    margin-bottom: 10px;
  }

  .token-option {
    display: flex;
    font-size: 14px;
    em {
      font-weight: bolder;
      margin-left: auto;
      font-style: normal;
    }
  }

  .invite {
    font-size: 12px;
    width: 600px;
    margin: 40px auto 0;

    span {
      font-size: 12px;
      user-select: all;
      cursor: pointer;
    }
  }
</style>
