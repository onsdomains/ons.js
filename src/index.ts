import { ExternalProvider, JsonRpcFetchFunc, JsonRpcSigner, Web3Provider } from "@ethersproject/providers";
import { Contract, ethers } from "ethers";
import ONSRegister from "./contracts/ONSRegsiter";
import RegisterController from "./contracts/RegisterController";
const Provider = ethers.providers.Provider


interface OnsOptionsInterface {
    provider: Web3Provider,
}



const errorHandling = (error: any) => {
    if (error.reason == 'ONS: NAME_EXPIRIES' || error.reason == 'ONS: THIS_ADDRESS_IS_NOT_OWNER_ANYMORE') {
        throw new Error("User does not have a primary name");
    } else {
        console.log(error);
        throw new Error(error);
    }
}
const addressIsValid = (address: string): boolean => {
    return /^0x[0-9a-fA-F]{40}$/.test(address);
}

export default class ONS {
    private provider: Web3Provider;
    private signer: JsonRpcSigner;
    private RegisterControllerC: Contract; // register controller
    private ONSRegisterC: Contract; // ons register
    constructor(options: OnsOptionsInterface) {
        const { provider } = options
        let ethersProvider
        if (Provider.isProvider(provider)) {
            //detect ethersProvider
            ethersProvider = provider
        } else {
            ethersProvider = new ethers.providers.Web3Provider(provider)
        }
        this.RegisterControllerC = new ethers.Contract(RegisterController.address, RegisterController.abi).connect(ethersProvider)
        this.ONSRegisterC = new ethers.Contract(ONSRegister.address, ONSRegister.abi).connect(ethersProvider)
        this.provider = ethersProvider
        this.signer = ethersProvider.getSigner()
    }

    getName = async (address: string): Promise<string | undefined> => {
        if (!addressIsValid(address)) {
            throw new Error("Invalid address");
        }
        try {
            const res = await this.ONSRegisterC.getName(address)
            return res
        } catch (error: any) {
            errorHandling(error)
        }
    }

    getAddress = async (name: string): Promise<string | undefined> => {

        try {
            const res = await this.ONSRegisterC.getAddress(name)
            if (res == undefined) {
                throw new Error("This name does not exist");
            } else {
                return res
            }
        } catch (error: any) {
            console.log(error)
        }
    }


}