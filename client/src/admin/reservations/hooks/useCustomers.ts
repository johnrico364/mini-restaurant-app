import { useQuery } from "@tanstack/react-query";
import axios from "axios";

// GET ALL RESERVATIONS
export const useCustomers = () => {
  return useQuery({
    queryKey: ["customers"],
    queryFn: async () => {
      const { data: customers } = await axios.get(
        "https://my-json-server.typicode.com/johnrico364/mini-restaurant-app/customers"
      );

      return customers;
    },
  });
};
